package com.redmoon.oa.flow.strategy;

import cn.js.fan.util.ErrMsgException;
import com.redmoon.kit.util.FileUpload;
import com.redmoon.oa.flow.MyActionDb;
import com.redmoon.oa.flow.WorkflowActionDb;
import com.redmoon.oa.flow.WorkflowDb;
import org.apache.log4j.Logger;

import javax.servlet.http.HttpServletRequest;
import java.util.Vector;

public class AtLeastSelectOne implements IStrategy {
    private int x;

    public AtLeastSelectOne() {

    }

    /**
     * 在matchActionUser中预先匹配人员
     */
    public Vector selectUser(Vector userVector) {
        // 如果此处不返回null，则因为在matchActionUser会置WorkflowActionDb中的userNames，会使得userVector所有的人员会处理，而不是选中的人员
        return null;
    }

    /**
     * 是否處理者可以選擇
     * @return
     */
    public boolean isSelectable() {
        return true;
    }

    public boolean onActionFinished(HttpServletRequest request, WorkflowDb wf,
                                    MyActionDb mad) {
        return true;
    }

    public void setX(int x) {
        this.x = x;
    }

    public void validate(HttpServletRequest request, WorkflowDb wf, WorkflowActionDb myAction, long myActionId, FileUpload fu, String[] userNames, WorkflowActionDb nextAction) throws ErrMsgException {
        if (userNames==null || userNames.length==0) {
            throw new ErrMsgException("在节点“" + nextAction.getTitle() + "”上，请选择至少一个用户");
        }
    }

    /**
     * 默认全部人员是否选中
     */
    public boolean isSelected() {
        return false;
    }

    public boolean isGoDown() {
        return false;
    }
}
