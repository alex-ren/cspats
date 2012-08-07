#ifndef CSPATS_LIB_H
#define CSPATS_LIB_H

#ifndef __cplusplus
#error
#endif

#include <unistd.h>
#include <pthread.h>
#include <semaphore.h>

class Reference {
public:
    /*
     * Name: ref
     * Return: current reference count after increasing
     */
    virtual unsigned int ref() = 0;

    /*
     * Name: unref
     * Return: current reference count after decreasing
     */
    virtual unsigned int unref() = 0;

};

class Alternative;

class Altable {
public:
    // When "enable" returns true, it knows that it will be selected.
    virtual bool enable(Alternative *pAlt) = 0;
    virtual void disable(bool care = false) = 0;
};

/*
 * Name: Alternative
 *
 */
class Alternative {
public:
    static Alternative * create(Altable* c[], size_t len);

    int select();
    bool schedule(Altable *alt); 

private:
    Alternative(Altable* c[], size_t len): 
        m_c(c), m_len(len),
        m_sync(), m_cond() {}
    virtual ~Alternative() {}

    Alternative(const Alternative &alt);  // no implementation
    Alternative & operator = (const Alternative &alt);  // no implementation


    int init();
    void finalize();

    enum State{
        eEnabling = 0,
        eWaiting = 1,
        eReady = 2,
        eInactive = 3
    };

private:
    Altable **m_c;  // array of Altable *
    Altable  *m_selector;
    size_t    m_len;
    State     m_state;

    pthread_mutex_t m_sync;
    pthread_cond_t  m_cond;
    
};

class Channel: public virtual Altable, Reference {
public:
    virtual void read(unsigned char *buffer, size_t len) = 0;
    virtual void write(unsigned char *buffer) = 0;
};


class One2OneChannel: public Channel {
public:
    /*
     * Name: create
     * Return: 
     *     non-null: success
     *     NULL: failure
     */
    static One2OneChannel * create();

    // Alt is only applicable on reading part of the channel
    bool enable(Alternative *pAlt);
    void disable(bool care = false);
    void read(unsigned char *buffer, size_t len);
    void write(unsigned char *buffer);
    unsigned int ref();
    unsigned int unref();

private:
    One2OneChannel(): m_uiCount(1), m_sync(), m_cond(), 
                      m_pBuff(NULL), m_bEmpty(true), 
                      m_pAlt(NULL) {}
    ~One2OneChannel() {};  // cannot be deleted by other classes

    // One2OneChannel cannot be copied.
    One2OneChannel(const One2OneChannel &);  // no implementation
    One2OneChannel & operator = (const One2OneChannel &);  // no implementation

    /*
     * Name: init
     * Return: 
     *     0: success
     *     other: failure
     */
    int init();

    void finalize();

private:
    unsigned int    m_uiCount;

    pthread_mutex_t m_sync;
    pthread_cond_t  m_cond;

    unsigned char * m_pBuff;
    bool            m_bEmpty;  // true means no thread has arrived
    Alternative   * m_pAlt;

};

class Many2OneChannel: public Channel {
public:
    static Many2OneChannel * create();

    // Alt is only applicable on reading part of the channel
    bool enable(Alternative *pAlt);
    void disable(bool care = false);
    void read(unsigned char *buffer, size_t len);
    void write(unsigned char *buffer);
    unsigned int ref();
    unsigned int unref();

private:
    Many2OneChannel(): m_mxWrite(), m_pCh(NULL) {}
    ~Many2OneChannel() {};

    // Many2OneChannel cannot be copied.
    Many2OneChannel(const Many2OneChannel &);  // no implementation
    Many2OneChannel & operator = (const Many2OneChannel &);  // no implementation

    /*
     * Name: init
     * Return: 
     *    0: success 
     *    other: failure
     */
    int init();

    void finalize();
private:
    pthread_mutex_t m_mxWrite;  // mutex for multiple write
    One2OneChannel *m_pCh;

};

class MutexLock {
public:
    MutexLock(pthread_mutex_t &mutex);
    ~MutexLock();
private:
    pthread_mutex_t &m_mutex;
};

class Barrier2: public virtual Altable, Reference {
public:
    static Barrier2 * create();
    void sync();

    bool enable(Alternative *pAlt);
    void disable(bool care = false);

    unsigned int ref();
    unsigned int unref();

private:
    int init();
    void finalize();

private:
    Barrier2(): 
      m_uiCount(1), m_sem(), m_sync(), m_cond(), m_parts(0), m_pAlt(NULL) {}
    ~Barrier2() {};
    // Barrier2 cannot be copied.
    Barrier2(const Barrier2 &);  // no implementation
    Barrier2 & operator = (const Barrier2 &);  // no implementation

private:
    unsigned int    m_uiCount;  // reference count

    sem_t           m_sem;  //
    pthread_mutex_t m_sync;
    pthread_cond_t  m_cond;

    unsigned int    m_parts;

    Alternative   * m_pAlt;


};













#endif  // end of [CSPATS_LIB_H]






