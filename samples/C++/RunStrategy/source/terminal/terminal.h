#pragma once

/** Trading console terminal. */
class ConsoleTerminal : public indicore3::TAddRefImpl<indicore3::ITerminal>
{
 protected:
    /** Show the alert. */
    virtual bool alertMessage(indicore3::IInstance *instance, const char *instrument, double price, const char *signalname, double time, indicore3::IError **error);

    /** Play the sound. */
    virtual bool alertSound(indicore3::IInstance *instance, const char *file, bool recurrent, indicore3::IError **error);

    /** Send the email. */
    virtual bool alertEmail(indicore3::IInstance *instance, const char *to, const char *subject, const char *text, indicore3::IError **error);

    /** Execute order.

    @param cookie       The cookie for the async operation notification
    @param params       The value map with the order fields. The order fields corresponds
    to the fields of the 34 transport command.
    @param error        [output] The pointer to the error in case it occurred.
    @return             The request identifier or 0 in case error occurred.
    */
    virtual const char *executeOrder(indicore3::IInstance *instance, int cookie, indicore3::IValueMap *params, indicore3::IError **error);

    DECLARE_ID()
    DECLARE_ID_MAP()
};
