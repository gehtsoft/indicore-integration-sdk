#pragma once

/**
  This is a smart pointer that manages an object obtained via new expression
  and releases that object when AutoRelease itself is destroyed.
 */
template<class Releasable>
class AutoRelease
{
 public:
    /** Creates a new AutoRelease. */
    AutoRelease(Releasable *pObject = NULL)
        : mObject(pObject)
    {
    }

    /** Destroys an AutoRelease and releases the managed object. */
    ~AutoRelease()
    {
        destroy();
    }

    /** Returns a pointer to the managed object. */
    Releasable* get() const
    {
        return mObject;
    }

    /** Accesses the managed object. */
    Releasable* operator->() { return mObject; }

    /** Releases ownership of the managed object. */
    Releasable* release()
    {
        Releasable *tmp = mObject;
        mObject = NULL;
        return tmp;
    }

    explicit AutoRelease(const AutoRelease &);

 private:
    AutoRelease & operator =(const AutoRelease &);

    void destroy()
    {
        if (NULL != mObject)
        {
            mObject->release();
            mObject = NULL;
        }
    }
    
    Releasable *mObject;
};
