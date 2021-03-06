
#include "cspats_lib.h"

#include "common/headers.h"
#include "common/ec.h"

#include <new>


MutexLock::MutexLock(pthread_mutex_t &mutex): m_mutex(mutex)
{
    // No error should occur logically.
    ec_rv ( pthread_mutex_lock(&m_mutex) )
    return;

EC_CLEANUP_BGN
    exit(EXIT_FAILURE);
EC_CLEANUP_END
}

MutexLock::~MutexLock()
{
    // No error should occur logically.
    ec_rv ( pthread_mutex_unlock(&m_mutex) )
    return;

EC_CLEANUP_BGN
    exit(EXIT_FAILURE);
EC_CLEANUP_END
}


One2OneChannel * One2OneChannel::create()
{
    One2OneChannel *p = NULL;
    int r = 0;
    ec_extra_null( p = new (std::nothrow) One2OneChannel() )

    ec_extra_nzero( r = p->init() )

    return p;

EC_CLEANUP_BGN
    if (NULL != p)
    {
       delete p;
    }
    return NULL;
EC_CLEANUP_END

}

unsigned int One2OneChannel::ref()
{
    // atomic variable operation provided by gcc
    return __sync_add_and_fetch(&m_uiCount, 1);
}


unsigned int One2OneChannel::unref()
{
    // atomic variable operation provided by gcc
    unsigned int ref = __sync_sub_and_fetch(&m_uiCount, 1);
    if (0 == ref)
    {
       this->finalize();
       delete this;
    }
    return ref;
}

void One2OneChannel::finalize()
{
    ec_rv_fatal( pthread_mutex_destroy(&m_sync) )
    ec_rv_fatal( pthread_cond_destroy(&m_cond) )
}

int One2OneChannel::init() {
    int rm = -1;
    int rc = -1;
   
    ec_rv( rm = pthread_mutex_init(&m_sync, NULL) )
    ec_rv( rc = pthread_cond_init(&m_cond, NULL) )

    // EC_LOG("success");
    return 0;

EC_CLEANUP_BGN
    if (0 == rm)
    {
       // No error should occur logically.
       ec_rv_fatal( pthread_mutex_destroy(&m_sync) )
    }

    return -1;
EC_CLEANUP_END
}


void One2OneChannel::read(unsigned char *buffer, size_t len)
{
    MutexLock aLock(m_sync);

    if (true == m_bEmpty)
    {
       // One thread has arrived.
       m_bEmpty = false;

       // No error should occur logically.
       // The "wait" shall be waken up only by cond.signal from the writer.
       // Wait till the writer comes.
       ec_rv_fatal( pthread_cond_wait(&m_cond, &m_sync) )

       memcpy(buffer, m_pBuff, len);

       // No error should occur logically.
       ec_rv_fatal( pthread_cond_signal(&m_cond) )
    }
    else
    {
       // Second thread has arrived, go to initial state.
       m_bEmpty = true;
       memcpy(buffer, m_pBuff, len);

       // No error should occur logically.
       ec_rv_fatal( pthread_cond_signal(&m_cond) )
    }
}


void One2OneChannel::write(unsigned char *buffer)
{
    MutexLock aLock(m_sync);

    m_pBuff = buffer;

    if (true == m_bEmpty)
    {
       // One thread has arrived.
       m_bEmpty = false;

       if (NULL != m_pAlt)
       {
           m_pAlt->schedule(this);
       }

       // No error should occur logically.
       // The "wait" shall be waken up only by cond.signal from the reader.
       // Wait till the reader comes and finishes reading.
       ec_rv_fatal( pthread_cond_wait(&m_cond, &m_sync) )
    }
    else
    {
       // Second thread has arrived, go to initial state.
       m_bEmpty = true;

       // No error should occur logically.
       ec_rv_fatal( pthread_cond_signal(&m_cond) )

       // No error should occur logically.
       // Reader has already come.
       // Wait till the reader finishes reading.
       // The "wait" shall be waken up only by cond.signal from the reader.
       ec_rv_fatal( pthread_cond_wait(&m_cond, &m_sync) )
    }
}

/*
* Name: One2OneChannel::enable
* Return:
*     true: the channel is ready for reading
*/
bool One2OneChannel::enable(Alternative *pAlt)
{
    INSTANT_TRACE("")
    MutexLock aLock(m_sync);
    if (true == m_bEmpty)
    {
        INSTANT_TRACE("")
        m_pAlt = pAlt;
        return false;
    }
    else
    {
        INSTANT_TRACE("")
        return true;
    }
}

/*
* Name: One2OneChannel::disable
* Return:
*     
*/
void One2OneChannel::disable(bool care)
{
    MutexLock aLock(m_sync);
    m_pAlt = NULL;
    return;
}



Many2OneChannel * Many2OneChannel::create()
{
    Many2OneChannel *p = NULL;
    int r = 0;
    ec_extra_null( p = new (std::nothrow) Many2OneChannel() )

    ec_extra_nzero( r = p->init() )

    return p;

EC_CLEANUP_BGN
    if (0 != r)
    {
       delete p;
    }
    return NULL;
EC_CLEANUP_END

}

int Many2OneChannel::init()
{
    int r_sync = -1;
    int r_cond = -1;
    int r_mx = -1;
    int r_cd = -1;

    ec_rv( r_sync = pthread_mutex_init(&m_sync, NULL) )
    ec_rv( r_cond = pthread_cond_init(&m_cond, NULL) )
    ec_rv( r_mx = pthread_mutex_init(&m_mxReader, NULL) )
    ec_rv( r_cd = pthread_cond_init(&m_cdReader, NULL) )

    return 0;

EC_CLEANUP_BGN
    if (0 == r_sync)
    {
       // No error should occur logically.
       ec_rv_fatal( pthread_mutex_destroy(&m_sync) )
    }

    if (0 == r_cond)
    {
       // No error should occur logically.
       ec_rv_fatal( pthread_cond_destroy(&m_cond) )
    }

    if (0 == r_mx)
    {
       // No error should occur logically.
       ec_rv_fatal( pthread_mutex_destroy(&m_mxReader) )
    }
    return -1;
EC_CLEANUP_END
}

void Many2OneChannel::finalize()
{
    ec_rv_fatal( pthread_mutex_destroy(&m_sync) )
    ec_rv_fatal( pthread_cond_destroy(&m_cond) )
    ec_rv_fatal( pthread_mutex_destroy(&m_mxReader) )
    ec_rv_fatal( pthread_cond_destroy(&m_cdReader) )
}

bool Many2OneChannel::enable(Alternative *pAlt)
{
    MutexLock aLock(m_sync);
    INSTANT_TRACE("")
    if (m_ulWriter > 0)
    {
        INSTANT_TRACE("")
        ec_rv_fatal( pthread_cond_broadcast(&m_cond) )
    }
    INSTANT_TRACE("")
    m_pAlt = pAlt;

    // always return false
    return false;
}

void Many2OneChannel::disable(bool care)
{
    MutexLock aLock(m_sync);
    m_pAlt = NULL;
    return;
}

void Many2OneChannel::read(unsigned char *buffer, size_t len)
{
    ec_rv_fatal( pthread_mutex_lock(&m_sync) )

    m_func = NULL;  // set checking function
    m_env = NULL;  // set checking function
    m_bReader = true;

    if (m_ulWriter > 0)
    {
        // wake up one writer
        ec_rv_fatal( pthread_cond_signal(&m_cond) )
    }

    ec_rv_fatal( pthread_mutex_lock(&m_mxReader) )
    ec_rv_fatal( pthread_mutex_unlock(&m_sync) )

    // wait till be waken by writer
    ec_rv_fatal( pthread_cond_wait(&m_cdReader, &m_mxReader) )
    ec_rv_fatal( pthread_mutex_unlock(&m_mxReader) )

    ec_rv_fatal( pthread_mutex_lock(&m_sync) )
    memcpy(buffer, m_pBuff, len);
    m_pBuff = NULL;
    m_bReader = false;

    ec_rv_fatal( pthread_mutex_unlock(&m_sync) )

    return;
}

void Many2OneChannel::cond_read(unsigned char *buffer, 
                                   size_t len,
                                   guard_func func,
                                   void * env)
{
    ec_rv_fatal( pthread_mutex_lock(&m_sync) )

    m_func = func;  // set checking function
    m_env = env;  // set checking function
    m_bReader = true;

    if (m_ulWriter > 0)
    {
        // wake up one writer
        ec_rv_fatal( pthread_cond_signal(&m_cond) )
    }

    ec_rv_fatal( pthread_mutex_lock(&m_mxReader) )
    ec_rv_fatal( pthread_mutex_unlock(&m_sync) )

    // wait till be waken by writer
    ec_rv_fatal( pthread_cond_wait(&m_cdReader, &m_mxReader) )
    ec_rv_fatal( pthread_mutex_unlock(&m_mxReader) )

    ec_rv_fatal( pthread_mutex_lock(&m_sync) )
    memcpy(buffer, m_pBuff, len);
    m_pBuff = NULL;
    m_bReader = false;
    m_func = NULL;
    m_env = NULL;

    ec_rv_fatal( pthread_mutex_unlock(&m_sync) )

    return;
}

void Many2OneChannel::write(unsigned char *buffer)
{
    MutexLock aLock(m_sync);
    ++m_ulWriter;

    if (NULL != m_pAlt)
    {
        m_pAlt->schedule(this);
    }

    while (false == m_bReader ||
           NULL != m_pBuff    ||
           (NULL != m_func && (false == m_func(buffer, m_env)))
           )
    {
        ec_rv_fatal( pthread_cond_wait(&m_cond, &m_sync) )
    }

    m_pBuff = buffer;

    // wake up reader
    ec_rv_fatal( pthread_mutex_lock(&m_mxReader) )
    ec_rv_fatal( pthread_cond_signal(&m_cdReader) )
    ec_rv_fatal( pthread_mutex_unlock(&m_mxReader) )

    --m_ulWriter;
    
    return;
}

unsigned int Many2OneChannel::ref()
{
    // atomic variable operation provided by gcc
    return __sync_add_and_fetch(&m_uiCount, 1);
}

unsigned int Many2OneChannel::unref()
{
    // atomic variable operation provided by gcc
    unsigned int ref = __sync_sub_and_fetch(&m_uiCount, 1);
    if (0 == ref)
    {
       this->finalize();
       delete this;
    }
}

Alternative * Alternative::create(Altable *c[], size_t len)
{
    Alternative *p = NULL;
    int r = 0;
    ec_extra_null( p = new (std::nothrow) Alternative(c, len) )

    ec_extra_nzero( r = p->init() )

    return p;

EC_CLEANUP_BGN
    if (0 != r)
    {
       delete p;
    }
    return NULL;
EC_CLEANUP_END
}

int Alternative::init()
{
    int rm = -1;
    int rc = -1;
   
    ec_rv( rm = pthread_mutex_init(&m_sync, NULL) )
    ec_rv( rc = pthread_cond_init(&m_cond, NULL) )

    // EC_LOG("success");
    return 0;

EC_CLEANUP_BGN
    if (0 == rm)
    {
       // No error should occur logically.
       ec_rv_fatal( pthread_mutex_destroy(&m_sync) )
    }

    return -1;
EC_CLEANUP_END
}

void Alternative::finalize()
{
    ec_rv_fatal( pthread_mutex_destroy(&m_sync) )
    ec_rv_fatal( pthread_cond_destroy(&m_cond) )
}

int Alternative::select()
{
    size_t bound = 0;
    INSTANT_TRACE("")

    m_state = eEnabling;
    for (bound = 0; bound < m_len; ++bound)
    {
        INSTANT_TRACE("")
        MutexLock aLock(m_sync);
        // nothing has been selected
        if (eReady != m_state)
        {
            INSTANT_TRACE_FMT("m_p[%d] is %x", bound, m_c[bound]);
            if ((((Altable *)(m_c[bound]))->enable(this)))
            {
                INSTANT_TRACE("")
                // one channel is ready for reading or
                // one barrier is ready for sync
                m_selector = m_c[bound];
                m_state = eReady;
                break;
            }
            INSTANT_TRACE("")
        }
        else
        {
            INSTANT_TRACE("")
            --bound;
            break;
        }
    }

    INSTANT_TRACE("")

    if (bound == m_len)
    {
        bound = bound - 1;
    }

    // lock protected
    {
        MutexLock aLock(m_sync);
        {
            INSTANT_TRACE("")
            if (eEnabling == m_state)
            {
                INSTANT_TRACE("")
                m_state = eWaiting;
                ec_rv_fatal( pthread_cond_wait(&m_cond, &m_sync) )
                // m_state = eReady;
            }
            INSTANT_TRACE("")
        }
    }

    size_t selected = m_len;
    // Now the state must be eReady
    for (int i = 0; i <= bound; ++i)
    {
        INSTANT_TRACE("")
        if (m_selector == m_c[i])
        {
            selected = i;
            m_c[i]->disable(true);
            INSTANT_TRACE("")
        }
        else
        {
            INSTANT_TRACE("")
            m_c[i]->disable(false);
        }
    }

    INSTANT_TRACE("")
    m_state = eInactive;
    return selected;
}

bool Alternative::schedule(Altable *alt)
{
    MutexLock aLock(m_sync);

    switch (m_state)
    {
    case eEnabling:
        m_state = eReady;
        m_selector = alt;
        return true;
    case eWaiting:
        m_state = eReady;
        m_selector = alt;
        ec_rv_fatal( pthread_cond_signal(&m_cond) )
        return true;
    case eReady:
        return false;
    default:  // eInactive
        return false;
    }
}


void Barrier2::sync()
{
    INSTANT_TRACE("")
    sem_wait(&m_sem);
    INSTANT_TRACE("Barrier2::sync  000000001")
    this->sync_sem();
    return;
}


// This function is used for sync after enable, which
// has grabbed the semaphore.
void Barrier2::sync_sem()
{
    INSTANT_TRACE("Barrier2::sync_sem  000000000")

    MutexLock aLock(m_sync);
    INSTANT_TRACE("Barrier2::sync_sem  000000002")

    ++m_parts;
    // first part to come (excluding used by alternative)
    if (2 != m_parts)  // maybe 1 or 3
    {
        INSTANT_TRACE("Barrier2::sync_sem  000000010")
        if (NULL != m_pAlt)
        {
            INSTANT_TRACE("Barrier2::sync_sem  000000011")
            m_pAlt->schedule(this);
        }
        INSTANT_TRACE("Barrier2::sync_sem  000000012")
        pthread_cond_wait(&m_cond, &m_sync);
        INSTANT_TRACE("Barrier2::sync_sem  000000013")
    }
    else  // assert m_parts == 2
    {
        INSTANT_TRACE("Barrier2::sync_sem  000000020")
        pthread_cond_signal(&m_cond);
        INSTANT_TRACE("Barrier2::sync_sem  000000021")
        m_parts -= 2; 
    }

    INSTANT_TRACE("Barrier2::sync_sem  000000030")
    sem_post(&m_sem);
    INSTANT_TRACE("Barrier2::sync_sem  000000031")
    return;
}


Barrier2 * Barrier2::create()
{
    Barrier2 *p = NULL;
    int r = 0;

    ec_extra_null( p = new (std::nothrow) Barrier2() )

    ec_extra_nzero( r = p->init() )

    return p;

EC_CLEANUP_BGN
    if (NULL != p)
    {
       delete p;
    }
    return NULL;
EC_CLEANUP_END

}

// take the semaphore with it when return
bool Barrier2::enable(Alternative *pAlt)
{
    INSTANT_TRACE("Barrier2::enable  0001")
    sem_wait(&m_sem);
    INSTANT_TRACE("Barrier2::enable  0002")

    MutexLock aLock(m_sync);
    INSTANT_TRACE("Barrier2::enable  0003")

    if (0 == m_parts)
    {   // first one to arrive
        INSTANT_TRACE("Barrier2::enable  0004")
        if (NULL == m_pAlt)
        {   // first alternative to arrive
            INSTANT_TRACE("Barrier2::enable  0005")
            m_pAlt = pAlt;
            return false;
        }
        else
        {
            INSTANT_TRACE("Barrier2::enable  0006")
            bool b = m_pAlt->schedule(this);  // wake up another alternative
            return b;
        }
        INSTANT_TRACE("Barrier2::enable  0007")
    }
    else  // second one to arrive
    {
        INSTANT_TRACE("Barrier2::enable  0008")
       m_pAlt = NULL;
       return true;
    }
}


void Barrier2::disable(bool care)
{
    MutexLock aLock(m_sync);

    m_pAlt = NULL;

    if (false == care)
    {
       sem_post(&m_sem);
    }

}

unsigned int Barrier2::ref()
{
    // atomic variable operation provided by gcc
    // INSTANT_TRACE("Barrier2::ref\n")
    return __sync_add_and_fetch(&m_uiCount, 1);
}


unsigned int Barrier2::unref()
{
    // atomic variable operation provided by gcc
    unsigned int ref = __sync_sub_and_fetch(&m_uiCount, 1);
    if (0 == ref)
    {
       this->finalize();
       delete this;
    }
    return ref;
}

int Barrier2::init() {
    int rs = -1;
    int rm = -1;
    int rc = -1;
   
    ec_neg1( rs = sem_init(&m_sem, 0, 2) )
    ec_rv( rm = pthread_mutex_init(&m_sync, NULL) )
    ec_rv( rc = pthread_cond_init(&m_cond, NULL) )

    // EC_LOG("success");
    return 0;

EC_CLEANUP_BGN
    if (0 == rs)
    {
       // No error should occur logically.
        ec_neg1_fatal( sem_destroy(&m_sem) )
    }

    if (0 == rm)
    {
        // No error should occur logically.
        ec_rv_fatal( pthread_mutex_destroy(&m_sync) )
    }

    return -1;
EC_CLEANUP_END
}

void Barrier2::finalize()
{
    ec_neg1_fatal( sem_destroy(&m_sem) )
    ec_rv_fatal( pthread_mutex_destroy(&m_sync) )
    ec_rv_fatal( pthread_cond_destroy(&m_cond) )
}















