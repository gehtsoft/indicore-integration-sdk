package com.fxtsmobile.indicoreloadindicators.core;

        import com.gehtsoft.indicore3.*;

public class HostTest extends BaseHostImpl {

    TerminalTest mTerminal = new TerminalTest();

    @Override
    public Terminal getTerminal() throws IndicoreException, IllegalStateException {
        return mTerminal;
    }
}
