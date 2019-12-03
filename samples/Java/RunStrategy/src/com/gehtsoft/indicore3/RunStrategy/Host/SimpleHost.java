package com.gehtsoft.indicore3.RunStrategy.Host;

import com.gehtsoft.indicore3.BaseHostImpl;
import com.gehtsoft.indicore3.IndicoreException;
import com.gehtsoft.indicore3.IndicoreObject;
import com.gehtsoft.indicore3.RunStrategy.Terminal.ConsoleTerminal;
import com.gehtsoft.indicore3.Terminal;

/** Simple Trading simulator host
 */
public class SimpleHost extends BaseHostImpl{
    Terminal mTerminal;

    @Override
    public void setAppPath(String appPath) throws IllegalStateException {
        super.setAppPath(appPath);
    }


    @Override
    public void trace(IndicoreObject caller, String trace) throws IllegalStateException {
        System.out.println(String.format("trace: %s", trace));
    }

    @Override
    public Terminal getTerminal() throws IndicoreException, IllegalStateException {
        return mTerminal;
    }

    public SimpleHost(){
        mTerminal = new ConsoleTerminal();
    }
}










