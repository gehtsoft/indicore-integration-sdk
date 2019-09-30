#pragma once

/** Simple Trading simulator host
*/
class SimpleHost : public indicore3::BaseHostImpl
{
    indicore3::ITerminal *mTerminal;

 public:
     SimpleHost();
     ~SimpleHost();

 protected:
    virtual void trace(indicore3::IObjectNoRef* caller, const char *str);
    virtual indicore3::ITerminal *getTerminal(indicore3::IError **error);
};
