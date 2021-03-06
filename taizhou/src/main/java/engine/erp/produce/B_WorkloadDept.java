package engine.erp.produce;

import engine.dataset.EngineDataSet;
import engine.dataset.EngineRow;
import engine.dataset.SequenceDescriptor;
import engine.dataset.RowMap;
import engine.action.BaseAction;
import engine.action.Operate;
import engine.web.observer.Obactioner;
import engine.web.observer.Obationable;
import engine.web.observer.RunData;
import engine.project.*;
import engine.html.*;
import engine.common.*;
import engine.erp.produce.ImportProcess;

import java.util.ArrayList;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.math.BigDecimal;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSession;

import com.borland.dx.dataset.*;
/**
 * <p>Title: 生产--工人工作量列表（按部门输入）</p>
 * <p>Description: 生产--工人工作量列表（按部门输入）<br>
 * <p>Copyright: Copyright (c) 2003</p>
 * <p>Company: </p>
 * @author 李建华
 * @version 1.0
 */

public final class B_WorkloadDept extends BaseAction implements Operate
{
  public  static final String SHOW_DETAIL = "10001";
  public  static final String DETAIL_SELECT_PROCESS = "10021";
  public  static final String DETAIL_SELECT_PRODUCT = "11021";
  public  static final String ONCHANGE = "10031";
  public  static final String GXMC_ONCHANGE = "10731";
  public  static final String DETAIL_ADD_PERSON = "15731";
  public  static final String PRODUCT_AUTO_ADD = "13658";
  public  static final String COMPLETE = "10011";//强制完成触发事件
  public  static final String PRODUCT_CHANGE = "11111";//手工输入产品编码触发事件
  public  static final String REPORT = "2000";//报表追踪操作
  public  static final String DELETE_BLANK = "2001";//删除产品编码为空操作


  private static final String MASTER_STRUT_SQL = "SELECT * FROM sc_bmgzl WHERE 1<>1";
  private static final String MASTER_SQL    = "SELECT * FROM sc_bmgzl WHERE ? AND fgsid=? ? ORDER BY djh DESC";
  private static final String DETAIL_STRUT_SQL = "SELECT * FROM sc_bmgzlmx WHERE 1<>1";
  private static final String DETAIL_SQL    = "SELECT * FROM sc_bmgzlmx WHERE bmgzlid='?'";//
  private static final String EMP_SQL    = "SELECT personid FROM emp WHERE isdelete='0' and deptid=";//
 //生产报表调用单据
  private static final String REPORT_SQL = "SELECT * FROM sc_bmgzl WHERE bmgzlid= ";

  private EngineDataSet dsMasterTable  = new EngineDataSet();//主表
  private EngineDataSet dsDetailTable  = new EngineDataSet();//从表

  private LookUp technicsBean = null; //工艺路线信息的bean的引用, 用于提取工艺路线信息

  public  HtmlTableProducer masterProducer = new HtmlTableProducer(dsMasterTable, "sc_bmgzl");
  public  HtmlTableProducer detailProducer = new HtmlTableProducer(dsDetailTable, "sc_bmgzlmx");
  private boolean isMasterAdd = true;    //是否在添加状态
  public boolean isDetailAdd = false; //从表是否在增加状态
  public boolean isReport = false;
  private long    masterRow = -1;         //保存主表修改操作的行记录指针
  private RowMap  m_RowInfo    = new RowMap(); //主表添加行或修改行的引用
  private ArrayList d_RowInfos = null; //从表多行记录的引用

  private boolean isInitQuery = false; //是否已经初始化查询条件
  private QueryBasic fixedQuery = new QueryFixedItem();
  public  String retuUrl = null;

  public ImportProcess  importprocessBean = null;//引入加工单的bean的引用, 用于提取引入加工单信息

  public  String loginId = ""; //登录员工的ID
  public  String loginDept = ""; //登录员工的部门
  public  String loginCode = ""; //登陆员工的编码
  public  String loginName = ""; //登录员工的姓名
  private String qtyFormat = null, priceFormat = null, sumFormat = null;
  private String fgsid = null;   //分公司ID
  private String bmgzlid = null;
  private User user = null;
  /**
   * 工作量列表（按部门输入）的实例
   * @param request jsp请求
   * @param isApproveStat 是否在审批状态
   * @return 返回工作量列表（按部门输入）的实例
   */
  public static B_WorkloadDept getInstance(HttpServletRequest request)
  {
    B_WorkloadDept workloadDeptBean = null;
    HttpSession session = request.getSession(true);
    synchronized (session)
    {
      String beanName = "workloadDeptBean";
      workloadDeptBean = (B_WorkloadDept)session.getAttribute(beanName);
      if(workloadDeptBean == null)
      {
        //引用LoginBean
        LoginBean loginBean = LoginBean.getInstance(request);

        workloadDeptBean = new B_WorkloadDept();
        workloadDeptBean.qtyFormat = loginBean.getQtyFormat();
        workloadDeptBean.sumFormat = loginBean.getSumFormat();
        workloadDeptBean.priceFormat = loginBean.getPriceFormat();

        workloadDeptBean.fgsid = loginBean.getFirstDeptID();
        workloadDeptBean.loginDept = loginBean.getDeptID();
        workloadDeptBean.loginId = loginBean.getUserID();
        workloadDeptBean.loginName = loginBean.getUserName();
        workloadDeptBean.user = loginBean.getUser();
        //设置格式化的字段
        workloadDeptBean.dsDetailTable.setColumnFormat("sl", workloadDeptBean.qtyFormat);
        workloadDeptBean.dsDetailTable.setColumnFormat("hssl", workloadDeptBean.qtyFormat);
        workloadDeptBean.dsDetailTable.setColumnFormat("desl", workloadDeptBean.qtyFormat);
        workloadDeptBean.dsDetailTable.setColumnFormat("jjdj", workloadDeptBean.priceFormat);
        workloadDeptBean.dsDetailTable.setColumnFormat("jjgz", workloadDeptBean.priceFormat);
        workloadDeptBean.dsDetailTable.setColumnFormat("jjgs", workloadDeptBean.priceFormat);
        session.setAttribute(beanName, workloadDeptBean);
      }
    }
    return workloadDeptBean;
  }

  /**
   * 构造函数
   */
  private B_WorkloadDept()
  {
    try {
      jbInit();
    }
    catch (Exception ex) {
      log.error("jbInit", ex);
    }
  }

  /**
   * 初始化函数
   * @throws Exception 异常信息
   */
  private final void jbInit() throws java.lang.Exception
  {
    setDataSetProperty(dsMasterTable, MASTER_STRUT_SQL);
    setDataSetProperty(dsDetailTable, DETAIL_STRUT_SQL);

    dsMasterTable.setSequence(new SequenceDescriptor(new String[]{"djh"}, new String[]{"SELECT pck_base.billNextCode('sc_bmgzl','djh') from dual"}));
    dsMasterTable.setSort(new SortDescriptor("", new String[]{"djh"}, new boolean[]{true}, null, 0));

    dsDetailTable.setSequence(new SequenceDescriptor(new String[]{"bmgzlmxid"}, new String[]{"s_sc_bmgzlmx"}));

    Master_Add_Edit masterAddEdit = new Master_Add_Edit();
    Master_Post masterPost = new Master_Post();
    addObactioner(String.valueOf(INIT), new Init());
    addObactioner(String.valueOf(FIXED_SEARCH), new Master_Search());
    addObactioner(SHOW_DETAIL, new ShowDetail());
    addObactioner(String.valueOf(ADD), masterAddEdit);
    addObactioner(String.valueOf(EDIT), masterAddEdit);
    addObactioner(String.valueOf(DEL), new Master_Delete());
    addObactioner(String.valueOf(POST), masterPost);
    addObactioner(String.valueOf(POST_CONTINUE), masterPost);
    addObactioner(String.valueOf(DETAIL_ADD), new Detail_Add());
    addObactioner(String.valueOf(DETAIL_DEL), new Detail_Delete());
    addObactioner(String.valueOf(ONCHANGE), new Onchange());
    addObactioner(String.valueOf(GXMC_ONCHANGE), new Gxmc_Onchange());
    addObactioner(String.valueOf(DETAIL_ADD_PERSON), new Detail_Add_Person());
    addObactioner(String.valueOf(DETAIL_SELECT_PROCESS), new Detail_Select_Process());
    addObactioner(String.valueOf(DETAIL_SELECT_PRODUCT), new Detail_Select_Product());
    addObactioner(String.valueOf(PRODUCT_AUTO_ADD), new Product_Auto_Add());
    addObactioner(String.valueOf(COMPLETE), new Complete());//强制完成事件
    addObactioner(String.valueOf(PRODUCT_CHANGE), new Product_Onchange());
    addObactioner(String.valueOf(REPORT), new Report());//报表引用事件
    addObactioner(String.valueOf(DELETE_BLANK), new Delete_Blank());//删除产品编码为空的行
  }

  //----Implementation of the BaseAction abstract class
  /**
   * JSP调用的函数
   * @param request 网页的请求对象
   * @param response 网页的响应对象
   * @return 返回HTML或javascipt的语句
   * @throws Exception 异常
   */
  public String doService(HttpServletRequest request, HttpServletResponse response)
  {
    try{
      String operate = request.getParameter(OPERATE_KEY);
      if(operate != null && operate.trim().length() > 0)
      {
        RunData data = notifyObactioners(operate, request, response, null);
        if(data == null)
          return showMessage("无效操作", false);
        if(data.hasMessage())
          return data.getMessage();
      }
      return "";
    }
    catch(Exception ex){
      if(dsMasterTable.isOpen() && dsMasterTable.changesPending())
        dsMasterTable.reset();
      log.error("doService", ex);
      return showMessage(ex.getMessage(), true);
    }
  }

  /**
   * Session失效时，调用的函数
   */
  public final void valueUnbound(HttpSessionBindingEvent event)
  {
    if(dsMasterTable != null){
      dsMasterTable.close();
      dsMasterTable = null;
    }
    if(dsDetailTable != null){
      dsDetailTable.close();
      dsDetailTable = null;
    }
    log = null;
    m_RowInfo = null;
    d_RowInfos = null;
    if(masterProducer != null)
    {
      masterProducer.release();
      masterProducer = null;
    }
    if(detailProducer != null)
    {
      detailProducer.release();
      detailProducer = null;
    }
  }

  /**
   * 得到子类的类名
   * @return 返回子类的类名
   */
  protected final Class childClassName()
  {
    return getClass();
  }

  /**
   * 初始化列信息
   * @param isAdd 是否时添加
   * @param isInit 是否从新初始化
   * @throws java.lang.Exception 异常
   */
  private final void initRowInfo(boolean isMaster, boolean isAdd, boolean isInit) throws java.lang.Exception
  {
    //是否是主表
    if(isMaster){
      if(isInit && m_RowInfo.size() > 0)
        m_RowInfo.clear();

      if(!isAdd)
        m_RowInfo.put(getMaterTable());
      else
      {
        String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        m_RowInfo.put("zdrq", today);
        m_RowInfo.put("zdr", loginName);
        m_RowInfo.put("zdrid", loginId);
        //m_RowInfo.put("deptid", loginDept);
        m_RowInfo.put("rq", today);
        m_RowInfo.put("zt","0");
      }
    }
    else
    {
      EngineDataSet dsDetail = dsDetailTable;
      if(d_RowInfos == null)
        d_RowInfos = new ArrayList(dsDetail.getRowCount());
      else if(isInit)
        d_RowInfos.clear();

      dsDetail.first();
      for(int i=0; i<dsDetail.getRowCount(); i++)
      {
        RowMap row = new RowMap(dsDetail);
        d_RowInfos.add(row);
        dsDetail.next();
      }
    }
  }
  /*得到主表一行的信息*/
  public final RowMap getMasterRowinfo() { return m_RowInfo; }

  /*得到从表多列的信息*/
  public final RowMap[] getDetailRowinfos() {
    RowMap[] rows = new RowMap[d_RowInfos.size()];
    d_RowInfos.toArray(rows);
    return rows;
  }

  /**
   * 主表是否在添加状态
   * @return 是否在添加状态
   */
  public final boolean masterIsAdd() {return isMasterAdd; }

  /**
   * 得到固定查询的用户输入的值
   * @param col 查询项名称
   * @return 用户输入的值
   */
  public final String getFixedQueryValue(String col)
  {
    return fixedQuery.getSearchRow().get(col);
  }
  /**
   * 从表保存操作
   * @param request 网页的请求对象
   * @param response 网页的响应对象
   * @return 返回HTML或javascipt的语句
   * @throws Exception 异常
   */
  private final void putDetailInfo(HttpServletRequest request)
  {
    RowMap rowInfo = getMasterRowinfo();
    //保存网页的所有信息
    rowInfo.put(request);

    int rownum = d_RowInfos.size();
    RowMap detailRow = null;
    for(int i=0; i<rownum; i++)
    {
      detailRow = (RowMap)d_RowInfos.get(i);
      detailRow.put("cpid", rowInfo.get("cpid_"+i));//产品
      detailRow.put("sl", formatNumber(rowInfo.get("sl_"+i), qtyFormat));//
      detailRow.put("hssl", formatNumber(rowInfo.get("hssl_"+i), qtyFormat));//
      detailRow.put("desl", formatNumber(rowInfo.get("desl_"+i), qtyFormat));//
      detailRow.put("jjdj", formatNumber(rowInfo.get("jjdj_"+i), priceFormat));//
      detailRow.put("jjgs", formatNumber(rowInfo.get("jjgs_"+i), priceFormat));//
      detailRow.put("jjgz", formatNumber(rowInfo.get("jjgz_"+i), priceFormat));//
      detailRow.put("gx", rowInfo.get("gx_"+i));//工序
      detailRow.put("gylxid", rowInfo.get("gylxid_"+i));//工艺路线
      detailRow.put("personid", rowInfo.get("personid_"+i));//员工
      detailRow.put("dmsxid", rowInfo.get("dmsxid_"+i));
      //保存用户自定义的字段
      FieldInfo[] fields = detailProducer.getBakFieldCodes();
      for(int j=0; j<fields.length; j++)
      {
        String fieldCode = fields[j].getFieldcode();
        detailRow.put(fieldCode, rowInfo.get(fieldCode + "_" + i));
      }
    }
  }

  /*得到表对象*/
  public final EngineDataSet getMaterTable()
  {
    return dsMasterTable;
  }

  /*得到从表表对象*/
  public final EngineDataSet getDetailTable(){
    if(!dsDetailTable.isOpen())
      dsDetailTable.open();
    return dsDetailTable;
  }

  /*打开从表*/
  public final void openDetailTable(boolean isMasterAdd)
  {
    String SQL = isMasterAdd ? "-1" : bmgzlid;
    SQL = combineSQL(DETAIL_SQL, "?", new String[]{SQL});

    dsDetailTable.setQueryString(SQL);
    if(!dsDetailTable.isOpen())
      dsDetailTable.open();
    else
      dsDetailTable.refresh();
  }

  /**
   * 得到选中的行的行数
   * @return 若返回-1，表示没有选中的行
   */
  public final int getSelectedRow()
  {
    if(masterRow < 0)
      return -1;

    dsMasterTable.goToInternalRow(masterRow);
    return dsMasterTable.getRow();
  }
  /**
   * 初始化操作的触发类
   */
  class Init implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      isReport = false;
      retuUrl = data.getParameter("src");
      retuUrl = retuUrl!= null ? retuUrl.trim() : retuUrl;
      //
      HttpServletRequest request = data.getRequest();
      masterProducer.init(request, loginId);
      detailProducer.init(request, loginId);
      //初始化查询项目和内容
      RowMap row = fixedQuery.getSearchRow();
      row.clear();
      String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
      String startDay = new SimpleDateFormat("yyyy-MM-01").format(new Date());
      row.put("rq$a", startDay);
      row.put("rq$b", today);
      isMasterAdd = true;
      isDetailAdd = false;
      //
      String SQL = "AND zt<>8";
      dsMasterTable.setQueryString(combineSQL(MASTER_SQL, "?", new String[]{user.getHandleDeptWhereValue("deptid", "zdrid"),fgsid, SQL}));
      dsMasterTable.setRowMax(null);
      if(dsDetailTable.isOpen() && dsDetailTable.getRowCount() > 0)
        dsDetailTable.empty();
      B_WageFormula.getInstance(request).readyExpressions();
    }
  }
  /**
   * 报表调用工人工作量操作的触发类
   */
  class Report implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      isReport = true;
      HttpServletRequest request = data.getRequest();
      masterProducer.init(request, loginId);
      detailProducer.init(request, loginId);
      String id = request.getParameter("bmgzlid");
      String SQL = REPORT_SQL+id;
      dsMasterTable.setQueryString(SQL);
      if(dsMasterTable.isOpen()){
        dsMasterTable.readyRefresh();
        dsMasterTable.refresh();
      }
      else
        dsMasterTable.open();

      bmgzlid = dsMasterTable.getValue("gzlid");
      B_WageFormula.getInstance(request).readyExpressions();
      //打开从表
      openDetailTable(false);

      initRowInfo(true, false, true);
      initRowInfo(false, false, true);
    }
  }
  /**
   * 显示从表的列表信息
   */
  class ShowDetail implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      dsMasterTable.goToRow(Integer.parseInt(data.getParameter("rownum")));
      masterRow = dsMasterTable.getInternalRow();
      bmgzlid = dsMasterTable.getValue("bmgzlid");
      //打开从表
      openDetailTable(false);
    }
  }
  /**
   * 删除产品编码为空白行操作
   */
  class Delete_Blank implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      putDetailInfo(data.getRequest());
      //EngineDataSet detail = getDetailTable();
      //while(detail.inBounds())
      String cpid = null;
      for(int i=0; i< d_RowInfos.size(); i++)
      {
        RowMap detailrow = (RowMap)d_RowInfos.get(i);
        cpid = detailrow.get("cpid");
        if(cpid.equals(""))
        {
          dsDetailTable.goToRow(i);
          d_RowInfos.remove(i);
          dsDetailTable.deleteRow();
          i--;
        }
      }
    }
  }
  /**
   * 主表添加或修改操作的触发类
   */
  class Master_Add_Edit implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      isDetailAdd = false;
      isReport = false;
      isMasterAdd = String.valueOf(ADD).equals(action);
      if(!isMasterAdd)
      {
        dsMasterTable.goToRow(Integer.parseInt(data.getParameter("rownum")));
        masterRow = dsMasterTable.getInternalRow();
        bmgzlid = dsMasterTable.getValue("bmgzlid");
      }
      synchronized(dsDetailTable){
        openDetailTable(isMasterAdd);
      }

      initRowInfo(true, isMasterAdd, true);
      initRowInfo(false, isMasterAdd, true);

      data.setMessage(showJavaScript("toDetail();"));
    }
  }

  /**
   * 主表保存操作的触发类
   */
  class Master_Post implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      putDetailInfo(data.getRequest());

      EngineDataSet ds = getMaterTable();
      RowMap rowInfo = getMasterRowinfo();
      //校验表单数据
      String temp = checkMasterInfo();
      if(temp != null)
      {
        data.setMessage(temp);
        return;
      }
      temp = checkDetailInfo();
      if(temp != null)
      {
        data.setMessage(temp);
        return;
      }
      if(!isMasterAdd)
        ds.goToInternalRow(masterRow);

      //得到主表主键值
      String bmgzlid = null;
      if(isMasterAdd){
        ds.insertRow(false);
        bmgzlid = dataSetProvider.getSequence("s_sc_bmgzl");
        ds.setValue("bmgzlid", bmgzlid);
        ds.setValue("fgsid", fgsid);
        ds.setValue("zdrq", new SimpleDateFormat("yyyy-MM-dd").format(new Date()));//制单日期
        ds.setValue("zdrid", loginId);
        ds.setValue("zdr", loginName);//操作员
        ds.setValue("zt","0");
      }
      //保存从表的数据
      String jjgsgs = B_WageFormula.getInstance(data.getRequest()).getWorkTime();
      double jjgsVal = isDouble(jjgsgs) ? Double.parseDouble(jjgsgs) : 0;
      RowMap detailrow = null;
      EngineDataSet detail = getDetailTable();
      //BigDecimal totalSum = new BigDecimal(0);
      detail.first();
      for(int i=0; i<detail.getRowCount(); i++)
      {
        detailrow = (RowMap)d_RowInfos.get(i);
        //新添的记录
        if(isMasterAdd)
          detail.setValue("bmgzlid", bmgzlid);

        double hsbl = detailrow.get("hsbl").length() > 0 ? Double.parseDouble(detailrow.get("hsbl")) : 0;//换算比例
        double sl = detailrow.get("sl").length()>0 ? Double.parseDouble(detailrow.get("sl")) : 0;
        double desl = detailrow.get("desl").length()>0 ? Double.parseDouble(detailrow.get("desl")) : 0;
        detail.setValue("cpid", detailrow.get("cpid"));
        detail.setValue("sl", detailrow.get("sl"));
        detail.setValue("hssl", String.valueOf(hsbl==0 ? 0 : sl/hsbl));
        detail.setValue("gylxid", detailrow.get("gylxid"));
        detail.setValue("gx", detailrow.get("gx"));//工序
        detail.setValue("desl", detailrow.get("desl"));//定额数量
        detail.setValue("jjdj", detailrow.get("jjdj"));//计件单价
        detail.setValue("jgdmxid", detailrow.get("jgdmxid"));
        detail.setValue("personid", detailrow.get("personid"));
        detail.setValue("jjgs", String.valueOf(desl==0 ? 0 : sl*jjgsVal/desl));//计件工时
        detail.setValue("jjgz", detailrow.get("jjgz"));//计件工资
        detail.setValue("dmsxid", detailrow.get("dmsxid"));
        //保存用户自定义的字段
        FieldInfo[] fields = detailProducer.getBakFieldCodes();
        for(int j=0; j<fields.length; j++)
        {
          String fieldCode = fields[j].getFieldcode();
          detail.setValue(fieldCode, detailrow.get(fieldCode));
        }
        detail.post();
        //totalSum = totalSum.add(detail.getBigDecimal("jjgz"));
        detail.next();
      }

      //保存主表数据
      ds.setValue("deptid", rowInfo.get("deptid"));//部门id
      ds.setValue("rq", rowInfo.get("rq"));//日期
      //保存用户自定义的字段
      FieldInfo[] fields = masterProducer.getBakFieldCodes();
      for(int j=0; j<fields.length; j++)
      {
        String fieldCode = fields[j].getFieldcode();
        detail.setValue(fieldCode, rowInfo.get(fieldCode));
      }
      ds.post();
      ds.saveDataSets(new EngineDataSet[]{ds, detail}, null);

      if(String.valueOf(POST_CONTINUE).equals(action)){
        isMasterAdd = true;
        initRowInfo(true, true, true);
        detail.empty();
        initRowInfo(false, true, true);//重新初始化从表的各行信息
      }
      else if(String.valueOf(POST).equals(action))
        data.setMessage(showJavaScript("backList();"));
    }
    /**
     * 校验从表表单信息从表输入的信息的正确性
     * @return null 表示没有信息
     */
    private String checkDetailInfo()
    {
      String temp = null;
      RowMap detailrow = null;
      if(d_RowInfos.size()<1)
        return showJavaScript("alert('不能保存空的数据')");
      ArrayList list = new ArrayList(d_RowInfos.size());
      String cpid=null, dmsxid=null, gylxid=null, gx=null, unit=null,personid=null;
      for(int i=0; i<d_RowInfos.size(); i++)
      {
        int row = i+1;
        detailrow = (RowMap)d_RowInfos.get(i);
        cpid = detailrow.get("cpid");
        dmsxid = detailrow.get("dmsxid");
        gylxid = detailrow.get("gylxid");
        gx= detailrow.get("gx");
        personid = detailrow.get("personid");
        if(gylxid.equals(""))
          return showJavaScript("alert('第"+row+"行工艺路线不能为空')");
        if(gx.equals(""))
          return showJavaScript("alert('第"+row+"行工序不能为空')");
        if(cpid.equals(""))
          return showJavaScript("alert('第"+row+"行产品不能为空！');");
        if(cpid.equals(""))
          return showJavaScript("alert('第"+row+"行产品不能为空');");
        if(personid.equals(""))
          return showJavaScript("alert('第"+row+"行员工不能为空！');");
        StringBuffer buf = new StringBuffer().append(personid).append(",").append(cpid).append(",").append(dmsxid).append(",").append(gylxid).append(",").append(gx);
        unit = buf.toString();
        if(list.contains(unit))
          return showJavaScript("alert('第"+row+"行产品重复');");
        else
          list.add(unit);
        String sl = detailrow.get("sl");
        if((temp = checkNumber(sl, "第"+row+"行数量")) != null)
          return temp;
        String hssl = detailrow.get("hssl");
        if((temp = checkNumber(hssl, "第"+row+"行换算数量")) != null)
          return temp;
        if(sl.length()>0 && sl.equals("0"))
          return showJavaScript("alert('第"+row+"行数量不能为零！');");
      }
      return null;
    }

    /**
     * 校验主表表表单信息从表输入的信息的正确性
     * @return null 表示没有信息,校验通过
     */
    private String checkMasterInfo()
    {
      RowMap rowInfo = getMasterRowinfo();
      String temp = rowInfo.get("rq");
      if(temp.equals(""))
        return showJavaScript("alert('日期不能为空！');");
      else if(!isDate(temp))
        return showJavaScript("alert('非法日期！');");
      temp = rowInfo.get("deptid");
      if(temp.equals(""))
        return showJavaScript("alert('请选择车间！');");
      return null;
    }
  }

  /**
   * 主表删除操作
   */
  class Master_Delete implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      if(isMasterAdd){
        data.setMessage(showJavaScript("backList();"));
        return;
      }
      EngineDataSet ds = getMaterTable();
      ds.goToInternalRow(masterRow);
      dsDetailTable.deleteAllRows();
      ds.deleteRow();
      ds.saveDataSets(new EngineDataSet[]{ds, dsDetailTable}, null);
      //
      d_RowInfos.clear();
      data.setMessage(showJavaScript("backList();"));
    }
  }
  /**
   *选择工艺路线类型触发的事件
   */
  class Onchange implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      HttpServletRequest req = data.getRequest();
      putDetailInfo(data.getRequest());
      int rownum = Integer.parseInt(data.getParameter("rownum"));
      RowMap detailRow = (RowMap)d_RowInfos.get(rownum);
      detailRow.put("gx","");
      detailRow.put("desl","");
      detailRow.put("jjdj","");
      detailRow.put("jjgs","");
      detailRow.put("jjgz","");
    }
  }
/**
 *选择工序类型触发的事件
 */
class Gxmc_Onchange implements Obactioner
{
  public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
  {
    HttpServletRequest req = data.getRequest();
    putDetailInfo(data.getRequest());
    String jjgsgs = B_WageFormula.getInstance(req).getWorkTime();
    double jjgsgsVal = isDouble(jjgsgs) ? Double.parseDouble(jjgsgs) : 0;
    int rownum = Integer.parseInt(data.getParameter("rownum"));
    String gxmcid = req.getParameter("v_gx_"+rownum);
    RowMap technicsRow = getTechnicsBean(req).getLookupRow(gxmcid);//根据工序id得到工艺路线明细的一行信息
    RowMap detailRow = (RowMap)d_RowInfos.get(rownum);
    double desl = technicsRow.get("desl").length()>0 ? Double.parseDouble(technicsRow.get("desl")) :0;
    double de = technicsRow.get("deje").length()>0 ? Double.parseDouble(technicsRow.get("deje")) : 0;//得到定额金额
    double sl = detailRow.get("sl").length()>0 ? Double.parseDouble(detailRow.get("sl")) : 0;
    detailRow.put("jjdj", technicsRow.get("deje"));
    detailRow.put("desl", technicsRow.get("desl"));
    if(sl!=0 && desl!=0)
      detailRow.put("jjgs",  formatNumber(String.valueOf(sl*jjgsgsVal/desl),priceFormat));
    if(sl!=0)
      detailRow.put("jjgz", formatNumber(String.valueOf(sl*de),priceFormat));
  }
}
/**
 *  查询操作
 */
  class Master_Search implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      initQueryItem(data.getRequest());
      fixedQuery.setSearchValue(data.getRequest());
      String SQL = fixedQuery.getWhereQuery();
      if(SQL.length() > 0)
        SQL = " AND "+SQL;
      SQL = combineSQL(MASTER_SQL, "?", new String[]{user.getHandleDeptWhereValue("deptid", "zdrid"),fgsid, SQL});
      dsMasterTable.setQueryString(SQL);
      dsMasterTable.setRowMax(null);
    }

    /**
     * 初始化查询的各个列
     * @param request web请求对象
     */
    private void initQueryItem(HttpServletRequest request)
    {
      if(isInitQuery)
        return;
      EngineDataSet master = dsMasterTable;
      EngineDataSet detail = dsMasterTable;
      if(!master.isOpen())
        master.open();
      //初始化固定的查询项目
      fixedQuery = new QueryFixedItem();
      fixedQuery.addShowColumn("", new QueryColumn[]{
        new QueryColumn(master.getColumn("djh"), null, null,null),
        new QueryColumn(master.getColumn("rq"), null, null, null, "a", ">="),
        new QueryColumn(master.getColumn("rq"), null, null, null, "b", "<="),
        new QueryColumn(master.getColumn("zt"), null, null, null, null, "="),//状态
        new QueryColumn(master.getColumn("deptid"), null, null, null, null, "="),//部门ID
        new QueryColumn(master.getColumn("bmgzlid"), "sc_bmgzlmx", "bmgzlid", "cpid", "cpid", "="),//从表品名
        new QueryColumn(master.getColumn("bmgzlid"), "sc_bmgzlmx", "bmgzlid", "personid", "personid", "="),//从表品名
        new QueryColumn(master.getColumn("bmgzlid"), "VW_SCBMGZL_QUERY", "bmgzlid", "cpbm", "cpbm", "like"),//从表产品编码
        new QueryColumn(master.getColumn("bmgzlid"), "VW_SCBMGZL_QUERY", "bmgzlid", "product", "product", "like"),//从表品名
      });
      isInitQuery = true;
    }
  }
 /**
  * 选择车间从表增加操作
  */
  class Detail_Add implements Obactioner
  {
    private EngineDataSet empdata = null;
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      HttpServletRequest req = data.getRequest();
      //保存输入的明细信息
      putDetailInfo(data.getRequest());
      RowMap rowinfo = getMasterRowinfo();
      isDetailAdd = true;
      String deptid = rowinfo.get("deptid");
      if(deptid.equals(""))
      {
        dsDetailTable.deleteAllRows();
        d_RowInfos.clear();
        return;
      }
      String SQL = EMP_SQL + deptid;
      if(empdata==null)
      {
        empdata = new EngineDataSet();
        setDataSetProperty(empdata,null);
      }
      empdata.setQueryString(SQL);
      if(!empdata.isOpen())
        empdata.openDataSet();
      else
        empdata.refresh();

      dsDetailTable.deleteAllRows();
      d_RowInfos.clear();
      if(!isMasterAdd)
        dsMasterTable.goToInternalRow(masterRow);
      String bmgzlid = dsMasterTable.getValue("bmgzlid");
      EngineRow row = new EngineRow(dsDetailTable,"personid");
      empdata.first();
      for(int i=0; i<empdata.getRowCount(); i++)
      {
        empdata.copyTo(row);
        dsDetailTable.addRow(row);
        dsDetailTable.setValue("bmgzlid", isMasterAdd ? "" : bmgzlid);
        empdata.next();
      }
      initRowInfo(false, false, false);
    }
  }
  /**
  *  从表单个员工增加操作
  */
 class Detail_Add_Person implements Obactioner
 {
   public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
   {
     HttpServletRequest req = data.getRequest();
     //保存输入的明细信息
     putDetailInfo(data.getRequest());
     EngineDataSet detail = getDetailTable();
     EngineDataSet ds = getMaterTable();
     if(!isMasterAdd)
       ds.goToInternalRow(masterRow);
     String bmgzlid = dsMasterTable.getValue("bmgzlid");
     detail.insertRow(false);
     detail.setValue("bmgzlid", isMasterAdd ? "" : bmgzlid);
     detail.post();
     d_RowInfos.add(new RowMap());
   }
  }
  /**
   *  从表选择加工单操作
   */
  class Detail_Select_Process implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      HttpServletRequest req = data.getRequest();
      //保存输入的明细信息
      putDetailInfo(data.getRequest());
      int row = Integer.parseInt(req.getParameter("rownum"));
      String singleId = m_RowInfo.get("singleId_"+row);
      if(singleId.equals(""))
        return;
      RowMap importProcessRow = getProcessGoodsBean(req).getLookupRow(singleId);
      double sl = importProcessRow.get("sl").length()>0 ? Double.parseDouble(importProcessRow.get("sl")) : 0;
      double hsbl = importProcessRow.get("hsbl").length()>0 ? Double.parseDouble(importProcessRow.get("hsbl")) : 0;
      dsDetailTable.goToRow(row);
      RowMap detail = (RowMap)d_RowInfos.get(row);
      detail.put("jgdmxid", singleId);
      detail.put("cpid", importProcessRow.get("cpid"));
      detail.put("sl", importProcessRow.get("sl"));
      detail.put("hssl", formatNumber(String.valueOf(hsbl==0 ? 0 : sl/hsbl), qtyFormat));
      detail.put("gylxid",importProcessRow.get("gylxid"));
      detail.put("dmsxid", importProcessRow.get("dmsxid"));
      emptyRows(detail, new String[]{"gx","desl","jjgs","jjdj","jjgz"});//把数组中的这几个字段值设为空
    }
  }
  /**
   *  从表选择产品操作
   */
  class Detail_Select_Product implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
    HttpServletRequest req = data.getRequest();
    //保存输入的明细信息
    putDetailInfo(data.getRequest());
    int row = Integer.parseInt(req.getParameter("rownum"));
    String singleProduct = m_RowInfo.get("singleProduct_"+row);
    if(singleProduct.equals(""))
      return;
    dsDetailTable.goToRow(row);
    RowMap detail = (RowMap)d_RowInfos.get(row);
    detail.put("cpid", singleProduct);
    emptyRows(detail, new String[]{"jgdmxid","gylxid","gx","sl","hssl","desl","jjgs","jjdj","jjgz"});//把数组中的这几个字段值设为空
    }
  }
  /**
   *  从表输入产品编码和规格触发操作
   */
  class Product_Onchange implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      HttpServletRequest req = data.getRequest();
      //保存输入的明细信息
      putDetailInfo(data.getRequest());
      int row = Integer.parseInt(req.getParameter("rownum"));
      dsDetailTable.goToRow(row);
      RowMap detail = (RowMap)d_RowInfos.get(row);
      emptyRows(detail, new String[]{"jgdmxid","gylxid","gx","sl","hssl","desl","jjgs","jjdj","jjgz"});//把数组中的这几个字段值设为空
    }
  }
  /**
   *  清空Hash表的数据
   *  @param参数detail是一个Hash表
   *  @param参数是Hash表中的字段数组
  */
   private void emptyRows(RowMap detail, String[] fields)
   {
     int num = fields.length;
     for(int i=0; i<num; i++)
     {
       String filed = fields[i];
       detail.put(filed,"");
     }
   }
  /**
   *  强制完成触发事件
   */
  class Complete implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      int row = Integer.parseInt(data.getParameter("rownum"));
      dsMasterTable.goToRow(row);
      dsMasterTable.setValue("zt", "8");
      dsMasterTable.post();
      dsMasterTable.saveChanges();
    }
  }
  /**
   *  自动复制产品操作
   */
  class Product_Auto_Add implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      HttpServletRequest req = data.getRequest();
      //保存输入的明细信息
      putDetailInfo(data.getRequest());
      int row = Integer.parseInt(req.getParameter("rownum"));
      if(row==0)
        return;
      RowMap oldDetail = (RowMap)d_RowInfos.get(row-1);
      String oldCpid = oldDetail.get("cpid");
      String oldJgdmxid = oldDetail.get("jgdmxid");
      String oldDmsxid = oldDetail.get("dmsxid");
      if(oldCpid.equals(""))
        return;
      RowMap detail = (RowMap)d_RowInfos.get(row);
      String cpid = detail.get("cpid");
      if(cpid.equals("")){
        dsDetailTable.goToRow(row);
        detail.put("cpid",oldCpid);
        detail.put("jgdmxid",oldJgdmxid);
        detail.put("dmsxid", oldDmsxid);
      }
    }
  }
  /**
   *  从表删除操作
   */
  class Detail_Delete implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      putDetailInfo(data.getRequest());
      EngineDataSet ds = getDetailTable();
      int rownum = Integer.parseInt(data.getParameter("rownum"));
      //删除临时数组的一列数据
      d_RowInfos.remove(rownum);
      ds.goToRow(rownum);
      ds.deleteRow();
    }
  }
  /**
   * 得到用于查找生产加工单信息的bean
   * @param req WEB的请求
   * @return 返回用于查找生产加工单信息的bean
   */
  public ImportProcess getProcessGoodsBean(HttpServletRequest req)
    {
    if(importprocessBean == null)
      importprocessBean = ImportProcess.getInstance(req);
    return importprocessBean;
  }
  /**
   * 得到用于查找工艺路线明细信息的bean
   * @param req WEB的请求
   * @return 返回用于查找工艺路线明细信息的bean
   */
  public LookUp getTechnicsBean(HttpServletRequest req)
  {
    if(technicsBean == null){
      technicsBean = LookupBeanFacade.getInstance(req, SysConstant.BEAN_TECHNICS_PROCEDURE);
      technicsBean.regData(new String[]{});
    }
    return technicsBean;
  }
}
