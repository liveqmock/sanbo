package engine.erp.person.shengyu;

import engine.action.BaseAction;
import engine.action.Operate;
import engine.web.observer.Obactioner;
import java.util.*;
import engine.html.*;
import engine.dataset.EngineDataSet;
import engine.dataset.EngineRow;
import engine.dataset.SequenceDescriptor;
import engine.dataset.RowMap;
import engine.web.observer.Obationable;
import engine.web.observer.RunData;
import engine.web.upload.*;
import engine.common.*;
import engine.project.*;
import java.text.SimpleDateFormat;
import java.math.BigDecimal;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSession;

import com.borland.dx.dataset.*;

public final class B_EmployeeInfo extends BaseAction implements Operate
{
  public static final String OPERATE_SHOW  = "373889573";   //显示操作
  public static final String OPERATE_HIDDEN  = "8888553432";//显示操作
  public static final String DEFORMITY = "44444778998";     //残疾
  private static final String MASTER_STRUT_SQL = "SELECT * FROM emp WHERE 1<>1";
  private static final String MASTER_EDIT_SQL         = "SELECT * FROM emp WHERE personid='?' ";
  //取主表的结构
  private static final String MASTER_SQL    = "SELECT * FROM emp where isDelete<>1 and isdelete<>2 and isDelete<>9 ? order by bm";//对主表的参数化查询 isdelete,deptid,----默认不显示离职人员
  private static final String MASTER_SQLC   = "SELECT * FROM emp where isDelete<>1  and isDelete<>9 ? order by bm";//对主表的参数化查询 isdelete,deptid,---可查询离职人员2004.12.17增加
  private static final String SEARCH_SQL = "SELECT * FROM VW_EMPLOYEE WHERE 1=1 ? ";
  /*以下是对从表的条件查询,需提供personid参数.*/
  private static final String ZGJTQK_SQL    = "SELECT * FROM rl_zgjtqk WHERE personid= ";//职工家庭情况
  private static final String ZGGZJL_SQL    = "SELECT * FROM rl_zggzjl WHERE personid= ";//职工工作经历
  private static final String ZGBXQK_SQL    = "SELECT * FROM rl_zgbxqk WHERE personid= ";//职工保险情况
  private static final String ZGJYQK_SQL    = "SELECT * FROM rl_zgjyqk WHERE personid= ";//职工教育情况
  private static final String ZGPXQK_SQL    = "SELECT * FROM rl_zgpxqk WHERE personid= ";//职工培训情况
  private static final String ZGQTXX_SQL    = "SELECT * FROM rl_zgqtxx WHERE personid= ";//职工其他信息
  private static final String ZGYGZJ_SQL    = "SELECT * FROM rl_emp_cert WHERE personid= ";//职工有关证件
  private static final String ZGTCAH_SQL    = "SELECT * FROM rl_zgtcah WHERE personid= ";//职工特长爱好
  private static final String ZGXXBDMX_SQL    = "SELECT * FROM rl_emp_change WHERE rl_emp_change.state=1 AND personid= ";//职工信息变动
  private static final String ZGJCQK_SQL    = "SELECT * FROM rl_zgjcqk WHERE personid= ";//职工奖惩情况
  private static final String ZGCJQK_SQL    = "SELECT * FROM rl_zgcjqk WHERE personid= ";//职工残疾情况
  //操作
  public static final String ZGJTQK_ADD    = "9000";//职工家庭情况新增
  public static final String ZGJTQK_DEL    = "9001";//职工家庭情况删除操作
  public static final String ZGGZJL_ADD    = "9003";//职工工作经历新增
  public static final String ZGGZJL_DEL    = "9004";//职工工作经历删除操作
  public static final String ZGBXQK_ADD    = "9005";//职工保险情况新增
  public static final String ZGBXQK_DEL   = "9006";//职工保险情况删除操作
  public static final String ZGJYQK_ADD    = "9007";//职工教育情况新增
  public static final String ZGJYQK_DEL    = "9008";//职工教育情况删除操作
  public static final String ZGPXQK_ADD    = "9009";//职工培训情况新增
  public static final String ZGPXQK_DEL    = "9010";//职工培训情况删除操作
  public static final String ZGQTXX_ADD    = "9011";//职工其他信息新增
  public static final String ZGQTXX_DEL    = "9012";//职工其他信息删除操作
  public static final String ZGTCAH_ADD    = "9013";//职工特长爱好新增
  public static final String ZGTCAH_DEL    = "9014";//职工特长爱好删除操作
  public static final String ZGXXBDMX_ADD  = "9015";//职工信息变动新增
  public static final String ZGXXBDMX_DEL  = "9016";//职工信息变动删除操作
  public static final String ZGJCQK_ADD    = "9017";//职工奖惩情况新增
  public static final String ZGJCQK_DEL    = "9018";//职工奖惩情况删除操作
  public static final String ZGCJQK_ADD    = "9019";//职工残疾情况新增
  public static final String ZGCJQK_DEL    = "9020";//职工残疾情况新增
  public static final String ZGYGZJ_ADD    = "9021";//职工有关证件新增
  public static final String ZGYGZJ_DEL    = "9022";//职工有关证件删除
  public static final String FILE_UPLOAD   = "9023";//上传照片


  private transient File file = null;
  public String activetab = "SetActiveTab(INFO_EX,'INFO_EX_0')";//从表当前的div

  public static final String VIEW_DETAIL = "1055";   //主从明细
  public static final String OPERATE_SEARCH = "1066";//主表查询操作
  public static final String DELETE_RETURN = "1067"; //主从删除操作

  public static final String OPERATE_A = "1068"; //
  private EngineDataSet dsMasterList  = new EngineDataSet();

  /*主从表的数据集*/
  private EngineDataSet dsMasterTable  = new EngineDataSet();//主表
  private EngineDataSet dsrl_zgjtqk  = new EngineDataSet();//从表职工家庭情况
  private EngineDataSet dsrl_zgjyqk  = new EngineDataSet();//从表职工教育情况
  private EngineDataSet dsrl_zggzjl  = new EngineDataSet();//从表职工工作经历
  private EngineDataSet dsrl_zgpxqk  = new EngineDataSet();//从表职工培训情况
  private EngineDataSet dsrl_zgjcqk  = new EngineDataSet();//从表职工奖惩情况
  private EngineDataSet dsrl_zgtcah  = new EngineDataSet();//从表职工特长爱好
  private EngineDataSet dsrl_zgbxqk  = new EngineDataSet();//从表职工保险情况
  private EngineDataSet dsrl_zgxxbd  = new EngineDataSet();//从表职工信息变动
  private EngineDataSet dsrl_zgqtxx  = new EngineDataSet();//从表职工其他信息
  private EngineDataSet dsrl_zgygzj  = new EngineDataSet();//从表职工有关证件
  private EngineDataSet dsrl_zgcjqk  = new EngineDataSet();//从表职工残疾情况

  private EngineDataSet dsSearchTable = new EngineDataSet();// 查询

  private boolean isMasterAdd = true;                          //主表是否在添加状态
  private long    masterRow = 0;                               //保存主表修改操作的行记录指针
  private RowMap  m_RowInfo    = new RowMap();                 //主表添加行或修改行的引用

  public ArrayList arraylist_rl_zgjtqk  = null;//从表职工家庭情况
  public ArrayList arraylist_rl_zgjyqk  = null;//从表职工教育情况
  public ArrayList arraylist_rl_zggzjl  = null;//从表职工工作经历
  public ArrayList arraylist_rl_zgpxqk  = null;//从表职工培训情况
  public ArrayList arraylist_rl_zgjcqk  = null;//从表职工奖惩情况
  public ArrayList arraylist_rl_zgtcah  = null;//从表职工特长爱好
  public ArrayList arraylist_rl_zgbxqk  = null;//从表职工保险情况
  public ArrayList arraylist_rl_zgxxbd  = null;//从表职工信息变动
  public ArrayList arraylist_rl_zgqtxx  = null;//从表职工其他信息
  public ArrayList arraylist_rl_zgygzj  = null;//从表职工有关证件
  public ArrayList arraylist_rl_zgcjqk  = null;//从表职工残疾情况

  private boolean isInitQuery = false;                         //是否已经初始化查询条件
  private QueryBasic fixedQuery = new QueryFixedItem();
  public  String retuUrl = null;
  private User user = null;
  public String deptid="";
  public String hth = "2";
  private String personid="";
  public  String czyid ="";

  /**
   * 职员档案卡
   * @param request jsp请求
   * @param isApproveStat 是否在审批状态
   * @return 返回销售合同列表的实例
   */
  public static B_EmployeeInfo getInstance(HttpServletRequest request)
  {
    B_EmployeeInfo b_employeeinfoBean = null;
    HttpSession session = request.getSession(true);
    synchronized (session)
    {
      String beanName = "b_employeeinfoBean_shengyu";
      b_employeeinfoBean = (B_EmployeeInfo)session.getAttribute(beanName);
      if(b_employeeinfoBean == null)
      {
        //引用LoginBean
        LoginBean loginBean = LoginBean.getInstance(request);
        b_employeeinfoBean = new B_EmployeeInfo();
        b_employeeinfoBean.user = loginBean.getUser();
        b_employeeinfoBean.czyid = loginBean.getUserID();
        session.setAttribute(beanName, b_employeeinfoBean);
      }
    }
    return b_employeeinfoBean;
  }

  /**
   * 构造函数
   */
  private B_EmployeeInfo()
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
    setDataSetProperty(dsMasterTable, combineSQL(MASTER_SQL,"?",new String[]{""}));
    setDataSetProperty(dsMasterList, combineSQL(MASTER_SQL,"?",new String[]{""}));

    setDataSetProperty(dsrl_zgjtqk, null);  //从表职工家庭情况
    setDataSetProperty(dsrl_zgjyqk, null);  //从表职工教育情况
    setDataSetProperty(dsrl_zggzjl, null);  //从表职工工作经历
    setDataSetProperty(dsrl_zgpxqk, null);  //从表职工培训情况
    setDataSetProperty(dsrl_zgjcqk, null);  //从表职工奖惩情况
    setDataSetProperty(dsrl_zgtcah, null);  //从表职工特长爱好
    setDataSetProperty(dsrl_zgbxqk, null);  //从表职工保险情况
    setDataSetProperty(dsrl_zgxxbd, null);  //从表职工信息变动
    setDataSetProperty(dsrl_zgqtxx, null);  //从表职工其他信息
    setDataSetProperty(dsrl_zgygzj, null);  //从表职工有关证件
    setDataSetProperty(dsrl_zgcjqk, null);  //从表职工残疾情况
    setDataSetProperty(dsSearchTable, combineSQL(SEARCH_SQL,"?",new String[]{""}));
    dsMasterTable.setSequence(new SequenceDescriptor(new String[]{"personid"}, new String[]{"s_emp"}));
    //dsMasterTable.setSort(new SortDescriptor("", new String[]{"deptid"}, new boolean[]{false}, null, 0));
    dsrl_zgjtqk.setSequence(new SequenceDescriptor(new String[]{"jtqkID"}, new String[]{"s_rl_zgjtqk"}));
    dsrl_zgjyqk.setSequence(new SequenceDescriptor(new String[]{"jyqkID"}, new String[]{"s_rl_zgjyqk"}));
    dsrl_zggzjl.setSequence(new SequenceDescriptor(new String[]{"gzjlID"}, new String[]{"s_rl_zggzjl"}));
    dsrl_zgpxqk.setSequence(new SequenceDescriptor(new String[]{"pxqkID"}, new String[]{"s_rl_zgpxqk"}));
    dsrl_zgjcqk.setSequence(new SequenceDescriptor(new String[]{"jcqkID"}, new String[]{"s_rl_zgjcqk"}));
    dsrl_zgtcah.setSequence(new SequenceDescriptor(new String[]{"tcahID"}, new String[]{"s_rl_zgtcah"}));
    dsrl_zgbxqk.setSequence(new SequenceDescriptor(new String[]{"bxqkID"}, new String[]{"s_rl_zgbxqk"}));
    dsrl_zgxxbd.setSequence(new SequenceDescriptor(new String[]{"chang_id"}, new String[]{"rl_emp_change"}));
    dsrl_zgqtxx.setSequence(new SequenceDescriptor(new String[]{"qtxxID"}, new String[]{"s_rl_zgqtxx"}));
    dsrl_zgygzj.setSequence(new SequenceDescriptor(new String[]{"certID"}, new String[]{"s_rl_emp_cert"}));//少主键值
    dsrl_zgcjqk.setSequence(new SequenceDescriptor(new String[]{"zgcjqkID"}, new String[]{"S_RL_ZGCJQK"}));
    Master_Add_Edit masterAddEdit = new Master_Add_Edit();
    Master_Post masterPost = new Master_Post();
    addObactioner(String.valueOf(INIT), new Init());//初始化
    addObactioner(String.valueOf(OPERATE_SEARCH), new Master_Search());//定制查询

    addObactioner(String.valueOf(ZGJTQK_ADD), new Rl_zgjtqk_adddel());//职工家庭情况新增删除操作
    addObactioner(String.valueOf(ZGJTQK_DEL), new Rl_zgjtqk_adddel());//职工家庭情况新增删除操作ZGJTQK_DEL
    addObactioner(String.valueOf(ZGJYQK_DEL), new Rl_zgjyqk_adddel());//职工教育情况新增删除操作
    addObactioner(String.valueOf(ZGJYQK_ADD), new Rl_zgjyqk_adddel());//职工教育情况新增删除操作
    addObactioner(String.valueOf(ZGGZJL_DEL), new Rl_zggzjl_adddel());//职工工作经历情况新增删除操作
    addObactioner(String.valueOf(ZGGZJL_ADD), new Rl_zggzjl_adddel());//职工工作经历情况新增删除操作
    addObactioner(String.valueOf(ZGPXQK_DEL), new Rl_zgpxqk_adddel());//职工培训情况新增删除操作
    addObactioner(String.valueOf(ZGPXQK_ADD), new Rl_zgpxqk_adddel());//职工培训情况新增删除操作
    addObactioner(String.valueOf(ZGJCQK_ADD), new Rl_zgjcqk_adddel());//职工奖惩情况新增删除操作
    addObactioner(String.valueOf(ZGJCQK_DEL), new Rl_zgjcqk_adddel());//职工奖惩情况新增删除操作

    addObactioner(String.valueOf(ZGTCAH_ADD), new Rl_zgtcah_adddel());//职工职工特长爱好新增删除操作
    addObactioner(String.valueOf(ZGTCAH_DEL), new Rl_zgtcah_adddel());//职工职工特长爱好新增删除操作
    //addObactioner(String.valueOf(ZGJCQK_ADD), new Rl_zgxxbd_adddel());//职工信息变动新增删除操作
    //addObactioner(String.valueOf(ZGJCQK_DEL), new Rl_zgxxbd_adddel());//职工信息变动新增删除操作
    //addObactioner(String.valueOf(ZGJCQK_ADD), new Rl_zgjcqk_adddel());//职工调薪情况新增删除操作
    //addObactioner(String.valueOf(ZGJCQK_DEL), new Rl_zgjcqk_adddel());//职工调薪情况新增删除操作
    addObactioner(String.valueOf(ZGBXQK_ADD), new Rl_zgbxqk_adddel());//职工保险情况新增删除操作
    addObactioner(String.valueOf(ZGBXQK_DEL), new Rl_zgbxqk_adddel());//职工保险情况新增删除操作
    addObactioner(String.valueOf(ZGQTXX_ADD), new Rl_zgqtxx_adddel());//职工其他情况新增删除操作
    addObactioner(String.valueOf(ZGQTXX_DEL), new Rl_zgqtxx_adddel());//职工其他情况新增删除操作
    addObactioner(String.valueOf(ZGYGZJ_ADD), new Rl_zgygzj_adddel());//职工有关证件新增删除操作
    addObactioner(String.valueOf(ZGYGZJ_DEL), new Rl_zgygzj_adddel());//职工有关证件新增删除操作
    //addObactioner(String.valueOf(ZGCJQK_ADD), new Rl_zgcjqk_adddel());//职工残疾情况
    //addObactioner(String.valueOf(ZGCJQK_DEL), new Rl_zgcjqk_adddel());//职工残疾情况

    addObactioner(String.valueOf(VIEW_DETAIL), masterAddEdit);//修改主表,及其对应的从表
    addObactioner(String.valueOf(DELETE_RETURN), new Master_Delete());//删除主表某一行,及其对应的从表
    //addObactioner(String.valueOf(DELETE), new Master_Delete());//删除主表某一行,及其对应的从表


    addObactioner(String.valueOf(ADD), masterAddEdit);
    addObactioner(String.valueOf(EDIT), masterAddEdit);
    addObactioner(String.valueOf(OPERATE_SHOW), new Master_Show());//显示
    addObactioner(String.valueOf(OPERATE_HIDDEN), new Master_Show());//不显示

    addObactioner(String.valueOf(DEL), new Master_Delete());

    addObactioner(String.valueOf(POST), masterPost);
    addObactioner(String.valueOf(OPERATE_A),  masterPost);//定制查询
    addObactioner(String.valueOf(POST_CONTINUE), masterPost);
    addObactioner(String.valueOf(DEFORMITY), new Defomity_Onchange());
    //
    addObactioner(FILE_UPLOAD, new UploadPhoto());
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
      String opearate = request.getParameter(OPERATE_KEY);
      if(opearate != null && opearate.trim().length() > 0)
      {
        RunData data = notifyObactioners(opearate, request, response, null);
        if(data == null)
          return showMessage("无效操作", false);
        if(data.hasMessage())
          return data.getMessage();
      }
      return "";
    }
    catch(Exception ex){
      if(dsMasterList.isOpen() && dsMasterList.changesPending())
        dsMasterList.reset();
      log.error("doService", ex);
      return showMessage(ex.getMessage(), true);
    }
  }

  /**
   * Session失效时，调用的函数
   */
  public final void valueUnbound(HttpSessionBindingEvent event)
  {
    if(dsMasterList != null){
      dsMasterList.close();
      dsMasterList = null;
    }
    if(dsMasterTable != null){
      dsMasterTable.close();
      dsMasterTable = null;
    }
    if(dsrl_zgjtqk != null){
      dsrl_zgjtqk.close();
      dsrl_zgjtqk = null;
    }
    if(dsrl_zgjyqk != null){
      dsrl_zgjyqk.close();
      dsrl_zgjyqk = null;
    }
    if(dsrl_zggzjl != null){
      dsrl_zggzjl.close();
      dsrl_zggzjl = null;
    }
    if(dsrl_zgpxqk != null){
      dsrl_zgpxqk.close();
      dsrl_zgpxqk = null;
    }
    if(dsrl_zgjcqk != null){
      dsrl_zgjcqk.close();
      dsrl_zgjcqk = null;
    }
    if(dsrl_zgtcah != null){
      dsrl_zgtcah.close();
      dsrl_zgtcah = null;
    }
    if(dsrl_zgbxqk != null){
      dsrl_zgbxqk.close();
      dsrl_zgbxqk = null;
    }
    if(dsrl_zgxxbd != null){
      dsrl_zgxxbd.close();
      dsrl_zgxxbd = null;
    }
    if(dsrl_zgqtxx != null){
      dsrl_zgqtxx.close();
      dsrl_zgqtxx = null;
    }
    if(dsrl_zgygzj != null){
      dsrl_zgygzj.close();
      dsrl_zgygzj = null;
    }
    if(dsrl_zgcjqk != null){
      dsrl_zgcjqk.close();
      dsrl_zgcjqk = null;
    }
    file = null;
    log = null;
    m_RowInfo = null;
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
   * 初始化行信息
   * @param isAdd 是否时添加
   * @param isInit 是否从新初始化
   * @throws java.lang.Exception 异常
   * 保存继续
   * 主表新增
   * 主表编辑
   */
  private final void initRowInfo(boolean isMaster, boolean isAdd, boolean isInit) throws java.lang.Exception
  {
    //是否是主表
    if(isMaster)
    {
      if(isInit && m_RowInfo.size() > 0)
        m_RowInfo.clear();
      if(!isAdd)
        m_RowInfo.put(getMaterTable());
    }
    else
    {
      openDetailTable();
      arraylist_rl_zgjtqk=putDetailToArraylist(dsrl_zgjtqk,arraylist_rl_zgjtqk);
      arraylist_rl_zgjyqk=putDetailToArraylist(dsrl_zgjyqk,arraylist_rl_zgjyqk);
      arraylist_rl_zggzjl=putDetailToArraylist(dsrl_zggzjl,arraylist_rl_zggzjl);
      arraylist_rl_zgpxqk=putDetailToArraylist(dsrl_zgpxqk,arraylist_rl_zgpxqk);
      arraylist_rl_zgjcqk=putDetailToArraylist(dsrl_zgjcqk,arraylist_rl_zgjcqk);
      arraylist_rl_zgtcah=putDetailToArraylist(dsrl_zgtcah,arraylist_rl_zgtcah);
      arraylist_rl_zgbxqk=putDetailToArraylist(dsrl_zgbxqk,arraylist_rl_zgbxqk);
      arraylist_rl_zgxxbd=putDetailToArraylist(dsrl_zgxxbd,arraylist_rl_zgxxbd);
      arraylist_rl_zgqtxx=putDetailToArraylist(dsrl_zgqtxx,arraylist_rl_zgqtxx);
      arraylist_rl_zgygzj=putDetailToArraylist(dsrl_zgygzj,arraylist_rl_zgygzj);
      arraylist_rl_zgcjqk=putDetailToArraylist(dsrl_zgcjqk,arraylist_rl_zgcjqk);
    }
  }
  /**
   *把从表数据集数据推入到ArrayList中
   *
   * */
  private final ArrayList putDetailToArraylist(EngineDataSet dsDetail,ArrayList arrlist)
  {
    if(!dsDetail.isOpen())
      dsDetail.open();
    arrlist = new ArrayList(dsDetail.getRowCount());
    dsDetail.first();
    for(int i=0; i<dsDetail.getRowCount(); i++)
    {
      RowMap row = new RowMap(dsDetail);
      arrlist.add(row);
      dsDetail.next();
    }
    return arrlist;
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
    rowInfo.put(request);
    //职工家庭
    int rownum=arraylist_rl_zgjtqk.size();
    RowMap detailRow = null;
    for(int i=0; i<rownum; i++)
    {
      detailRow = (RowMap)arraylist_rl_zgjtqk.get(i);
      detailRow.put("personid", personid);//
      detailRow.put("cf", rowInfo.get("cf_"+i));//
      detailRow.put("xm", rowInfo.get("xm_"+i));//
      detailRow.put("zy", rowInfo.get("zy_"+i));//
      detailRow.put("csrq", rowInfo.get("csrq_"+i));//
      detailRow.put("bz", rowInfo.get("bz_"+i));//备注
      arraylist_rl_zgjtqk.set(i,detailRow);
    }
    //职工教育情况
    rownum=arraylist_rl_zgjyqk.size();
    for(int i=0; i<rownum; i++)
    {
      detailRow = (RowMap)arraylist_rl_zgjyqk.get(i);
      detailRow.put("personid", personid);//
      detailRow.put("byxx", rowInfo.get("byxx_"+i));//
      detailRow.put("sxzy", rowInfo.get("sxzy_"+i));//
      detailRow.put("zmr", rowInfo.get("zmr_"+i));//
      detailRow.put("kssj", rowInfo.get("jy_kssj_"+i));//
      detailRow.put("jssj", rowInfo.get("jy_jssj_"+i));//
      detailRow.put("bz", rowInfo.get("jy_bz_"+i));//
      arraylist_rl_zgjyqk.set(i,detailRow);
    }
    //职工工作经历
    rownum=arraylist_rl_zggzjl.size();
    for(int i=0; i<rownum; i++)
    {
      detailRow = (RowMap)arraylist_rl_zggzjl.get(i);
      detailRow.put("personid", personid);//
      detailRow.put("gzdw", rowInfo.get("gzdw_"+i));//
      detailRow.put("zw", rowInfo.get("zw_"+i));//
      detailRow.put("kssj", rowInfo.get("gz_kssj_"+i));//
      detailRow.put("jssj", rowInfo.get("gz_jssj_"+i));//
      detailRow.put("bz", rowInfo.get("gz_bz_"+i));//
      arraylist_rl_zggzjl.set(i,detailRow);
    }
    rownum=arraylist_rl_zgpxqk.size();
    //职工培训情况
    for(int i=0; i<rownum; i++)
    {
      detailRow = (RowMap)arraylist_rl_zgpxqk.get(i);
      detailRow.put("personid", personid);//
      detailRow.put("pxxm", rowInfo.get("pxxm_"+i));//
      detailRow.put("zzjg", rowInfo.get("zzjg_"+i));//
      detailRow.put("kssj", rowInfo.get("px_kssj_"+i));//
      detailRow.put("jssj", rowInfo.get("px_jssj_"+i));//
      detailRow.put("bz", rowInfo.get("px_bz_"+i));//
      arraylist_rl_zgpxqk.set(i,detailRow);
    }
    //职工奖惩情况
    rownum=arraylist_rl_zgjcqk.size();
    for(int i=0; i<rownum; i++)
    {
      detailRow = (RowMap)arraylist_rl_zgjcqk.get(i);
      detailRow.put("personid", personid);//
      detailRow.put("jcjg", rowInfo.get("jcjg_"+i));//
      detailRow.put("yy", rowInfo.get("yy_"+i));//
      detailRow.put("rq", rowInfo.get("rq_"+i));//
      detailRow.put("bz", rowInfo.get("jc_bz_"+i));//
      arraylist_rl_zgjcqk.set(i,detailRow);
    }
    //职工特长爱好
    rownum=arraylist_rl_zgtcah.size();
    for(int i=0; i<rownum; i++)
    {
      detailRow = (RowMap)arraylist_rl_zgtcah.get(i);
      detailRow.put("personid", personid);//
      detailRow.put("tcah", rowInfo.get("tcah_"+i));//
      detailRow.put("djzs", rowInfo.get("djzs_"+i));//
      detailRow.put("fzjg", rowInfo.get("fzjg_"+i));//
      detailRow.put("fzrq", rowInfo.get("fzrq_"+i));//fzrq
      detailRow.put("bz", rowInfo.get("tc_bz_"+i));//
      arraylist_rl_zgtcah.set(i,detailRow);
    }
    //职工保险
    rownum=arraylist_rl_zgbxqk.size();
    for(int i=0; i<rownum; i++)
    {
      detailRow = (RowMap)arraylist_rl_zgbxqk.get(i);
      detailRow.put("personid", personid);//
      detailRow.put("xz", rowInfo.get("xz_"+i));//
      detailRow.put("bxgs", rowInfo.get("bxgs_"+i));//
      detailRow.put("bxrq", rowInfo.get("bxrq_"+i));//
      detailRow.put("shsj", rowInfo.get("shsj_"+i));//
      detailRow.put("ylfy", rowInfo.get("ylfy_"+i));//
      detailRow.put("lpje", rowInfo.get("lpje_"+i));//
      detailRow.put("ce", rowInfo.get("ce_"+i));//
      detailRow.put("shbzts", rowInfo.get("shbzts_"+i));//
      detailRow.put("bxe", rowInfo.get("bxe_"+i));//fzrq
      detailRow.put("bz", rowInfo.get("bx_bz_"+i));//
      arraylist_rl_zgbxqk.set(i,detailRow);
    }
    //职工其他
    rownum=arraylist_rl_zgqtxx.size();
    for(int i=0; i<rownum; i++)
    {
      detailRow = (RowMap)arraylist_rl_zgqtxx.get(i);
      detailRow.put("personid", personid);//
      detailRow.put("qdrq", rowInfo.get("qdrq_"+i));//
      detailRow.put("hth", rowInfo.get("hth_"+i));//
      detailRow.put("syrq", rowInfo.get("syrq_"+i));//
      detailRow.put("htqx", rowInfo.get("htqx_"+i));//htqx
      detailRow.put("rzrq", rowInfo.get("rzrq_"+i));//
      detailRow.put("fjh", rowInfo.get("fjh_"+i));//
      detailRow.put("gh", rowInfo.get("gh_"+i));//
      detailRow.put("hk", rowInfo.get("hk_"+i));//
      detailRow.put("zzz", rowInfo.get("zzz_"+i));//
      arraylist_rl_zgqtxx.set(i,detailRow);
    }
    /*职工有关证件*/
    rownum=arraylist_rl_zgygzj.size();
    for(int i=0; i<rownum; i++)
    {
      detailRow = (RowMap)arraylist_rl_zgygzj.get(i);
      detailRow.put("personid", personid);//
      detailRow.put("certname", rowInfo.get("certname_"+i));//
      detailRow.put("certno", rowInfo.get("certno_"+i));//
      detailRow.put("startdate", rowInfo.get("startdate_"+i));//
      detailRow.put("enddate", rowInfo.get("enddate_"+i));//

      arraylist_rl_zgygzj.set(i,detailRow);
    }
    //职工残疾情况
    rownum=arraylist_rl_zgcjqk.size();
    for(int i=0; i<rownum; i++)
    {
      detailRow = (RowMap)arraylist_rl_zgcjqk.get(i);
      detailRow.put("personid", personid);//
      detailRow.put("cjrzh", rowInfo.get("cjrzh_"+i));//
      detailRow.put("azsj", rowInfo.get("azsj_"+i));//
      detailRow.put("gzgw", rowInfo.get("gzgw_"+i));//
      detailRow.put("cjlb", rowInfo.get("cjlb_"+i));//htqx
      detailRow.put("bdr", rowInfo.get("bdr_"+i));//
      detailRow.put("bz", rowInfo.get("cjbz_"+i));//
      arraylist_rl_zgcjqk.set(i,detailRow);
    }
  }
  /*得到表对象*/
  public final EngineDataSet getMaterTable()
  {
    return dsMasterTable;
  }
  /*得到表对象*/
  public final EngineDataSet getMaterList()
  {
    return dsMasterList;
  }
  /*得到从表表对象*/
  public final EngineDataSet getzgjtqkTable(){return dsrl_zgjtqk;}
  public final EngineDataSet getZgjyqkTable(){return dsrl_zgjyqk;}
  public final EngineDataSet getZggzjlTable(){return dsrl_zggzjl;}
  public final EngineDataSet getzgpxqkTable(){return dsrl_zgpxqk;}
  public final EngineDataSet getzgjcqkTable(){return dsrl_zgjcqk;}
  public final EngineDataSet getzgtcahTable(){return dsrl_zgtcah;}
  public final EngineDataSet getzgbxqkTable(){return dsrl_zgbxqk;}
  public final EngineDataSet getzgxxbdTable(){return dsrl_zgxxbd;}
  public final EngineDataSet getzgqtxxTable(){return dsrl_zgqtxx;}
  public final EngineDataSet getzgygzjTable(){return dsrl_zgygzj;}
  public final EngineDataSet getzgcjqkTable(){return dsrl_zgcjqk;}

/*打开从表*/
  public final void openDetailTable()
  {
    /*职工家庭情况*/
    dsrl_zgjtqk.setQueryString(ZGJTQK_SQL + (isMasterAdd ? "-1" : personid));
    if(dsrl_zgjtqk.isOpen())
      dsrl_zgjtqk.refresh();
    else
      dsrl_zgjtqk.open();
    /*职工教育情况*/
    dsrl_zgjyqk.setQueryString(ZGJYQK_SQL + (isMasterAdd ? "-1" : personid));
    if(dsrl_zgjyqk.isOpen())
      dsrl_zgjyqk.refresh();
    else
      dsrl_zgjyqk.open();
    /*职工工作经历*/
    dsrl_zggzjl.setQueryString(ZGGZJL_SQL + (isMasterAdd ? "-1" : personid));
    if(dsrl_zggzjl.isOpen())
      dsrl_zggzjl.refresh();
    else
      dsrl_zggzjl.open();
    /*职工工培训情况*/
    dsrl_zgpxqk.setQueryString(ZGPXQK_SQL + (isMasterAdd ? "-1" : personid));
    if(dsrl_zgpxqk.isOpen())
      dsrl_zgpxqk.refresh();
    else
      dsrl_zgpxqk.open();
    /*职工奖惩情况*/
    dsrl_zgjcqk.setQueryString(ZGJCQK_SQL + (isMasterAdd ? "-1" : personid));
    if(dsrl_zgjcqk.isOpen())
      dsrl_zgjcqk.refresh();
    else
      dsrl_zgjcqk.open();
    /*职工特长爱好*/
    dsrl_zgtcah.setQueryString(ZGTCAH_SQL + (isMasterAdd ? "-1" : personid));
    if(dsrl_zgtcah.isOpen())
      dsrl_zgtcah.refresh();
    else
      dsrl_zgtcah.open();
    /*职工保险情况*/
    dsrl_zgbxqk.setQueryString(ZGBXQK_SQL + (isMasterAdd ? "-1" : personid));
    if(dsrl_zgbxqk.isOpen())
      dsrl_zgbxqk.refresh();
    else
      dsrl_zgbxqk.open();
    /*职工信息变动*/
    dsrl_zgxxbd.setQueryString(ZGXXBDMX_SQL + (isMasterAdd ? "-1" : personid));
    if(dsrl_zgxxbd.isOpen())
      dsrl_zgxxbd.refresh();
    else
      dsrl_zgxxbd.open();
    /*职工其他信息*/
    dsrl_zgqtxx.setQueryString(ZGQTXX_SQL + (isMasterAdd ? "-1" : personid));
    if(dsrl_zgqtxx.isOpen())
      dsrl_zgqtxx.refresh();
    else
      dsrl_zgqtxx.open();
    /*职工有关证件*/
    dsrl_zgygzj.setQueryString(ZGYGZJ_SQL + (isMasterAdd ? "-1" : personid));
    if(dsrl_zgygzj.isOpen())
      dsrl_zgygzj.refresh();
    else
      dsrl_zgygzj.open();
    /*职工残疾情况*/
    dsrl_zgcjqk.setQueryString(ZGCJQK_SQL + (isMasterAdd ? "-1" : personid));
    if(dsrl_zgcjqk.isOpen())
      dsrl_zgcjqk.refresh();
    else
      dsrl_zgcjqk.open();
  }

  /*得到主表一行的信息*/
  public final RowMap getMasterRowinfo() { return m_RowInfo; }
  /*得到从表多列的信息*/
  /*得到职工家庭情况从表的多行信息*/
  public final RowMap[] getZgjtqkRowinfos() {
    RowMap[] rows = new RowMap[arraylist_rl_zgjtqk.size()];
    arraylist_rl_zgjtqk.toArray(rows);
    return rows;
  }
  /*得到职工教育情况从表的多行信息*/
  public final RowMap[] getZgjyqkRowinfos() {
    RowMap[] rows = new RowMap[arraylist_rl_zgjyqk.size()];
    arraylist_rl_zgjyqk.toArray(rows);
    return rows;
  }
  /*得到职工工作经历从表的多行信息*/
  public final RowMap[] getZggzjlRowinfos() {
    RowMap[] rows = new RowMap[arraylist_rl_zggzjl.size()];
    arraylist_rl_zggzjl.toArray(rows);
    return rows;
  }
  /*得到职工培训情况从表的多行信息*/
  public final RowMap[] getZgpxqkRowinfos() {
    RowMap[] rows = new RowMap[arraylist_rl_zgpxqk.size()];
    arraylist_rl_zgpxqk.toArray(rows);
    return rows;
  }
  /*得到职工奖惩情况从表的多行信息*/
  public final RowMap[] getZgjcqkRowinfos() {
    RowMap[] rows = new RowMap[arraylist_rl_zgjcqk.size()];
    arraylist_rl_zgjcqk.toArray(rows);
    return rows;
  }
  /*得到职工特长爱好从表的多行信息*/
  public final RowMap[] getZgtcahRowinfos() {
    RowMap[] rows = new RowMap[arraylist_rl_zgtcah.size()];
    arraylist_rl_zgtcah.toArray(rows);
    return rows;
  }
  /*得到职工保险情况从表的多行信息*/
  public final RowMap[] getZgbxqkRowinfos() {
    RowMap[] rows = new RowMap[arraylist_rl_zgbxqk.size()];
    arraylist_rl_zgbxqk.toArray(rows);
    return rows;
  }
  /*得到职工其他情况从表的多行信息*/
  public final RowMap[] getZgqtxxRowinfos() {
    RowMap[] rows = new RowMap[arraylist_rl_zgqtxx.size()];
    arraylist_rl_zgqtxx.toArray(rows);
    return rows;
  }
    /*得到职工有关证件从表行信息*/
  public final RowMap[] getZgygzjRowinfos() {
    RowMap[] rows = new RowMap[arraylist_rl_zgygzj.size()];
    arraylist_rl_zgygzj.toArray(rows);
    return rows;
  }

  /*得到职工其信息变动*/
  public final RowMap[] getZgxxbdRowinfos() {
    RowMap[] rows = new RowMap[arraylist_rl_zgxxbd.size()];
    arraylist_rl_zgxxbd.toArray(rows);
    return rows;
  }
  /*得到职工残疾情况 */
  public final RowMap[] getZgcjqkRowinfos() {
    RowMap[] rows = new RowMap[arraylist_rl_zgcjqk.size()];
    arraylist_rl_zgcjqk.toArray(rows);
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
   *
   *初始化从表信息
   */
  public void initArrayList()
  {
    if(arraylist_rl_zgjtqk!=null){
      if(arraylist_rl_zgjtqk.size()>0)
      {
        arraylist_rl_zgjtqk.clear();
      }
    }
    if(arraylist_rl_zgjyqk!=null){
      if(arraylist_rl_zgjyqk.size()>0)
      {
        arraylist_rl_zgjyqk.clear();
      }
    }
    if(arraylist_rl_zggzjl!=null){
      if(arraylist_rl_zggzjl.size()>0)
      {
        arraylist_rl_zggzjl.clear();
      }
    }
    if(arraylist_rl_zgpxqk!=null){
      if(arraylist_rl_zgpxqk.size()>0)
      {
        arraylist_rl_zgpxqk.clear();
      }
    }
    if(arraylist_rl_zgjcqk!=null){
      if(arraylist_rl_zgjcqk.size()>0)
      {
        arraylist_rl_zgjcqk.clear();
      }
    }
    if(arraylist_rl_zgtcah!=null){
      if(arraylist_rl_zgtcah.size()>0)
      {
        arraylist_rl_zgtcah.clear();
      }
    }
    if(arraylist_rl_zgbxqk!=null){
      if(arraylist_rl_zgbxqk.size()>0)
      {
        arraylist_rl_zgbxqk.clear();
      }
    }
    if(arraylist_rl_zgxxbd!=null){
      if(arraylist_rl_zgxxbd.size()>0)
      {
        arraylist_rl_zgxxbd.clear();
      }
    }
    if(arraylist_rl_zgqtxx!=null){
      if(arraylist_rl_zgqtxx.size()>0)
      {
        arraylist_rl_zgqtxx.clear();
      }
    }
    if(arraylist_rl_zgygzj!=null){
      if(arraylist_rl_zgygzj.size()>0)
      {
        arraylist_rl_zgygzj.clear();
      }
    }
    if(arraylist_rl_zgcjqk!=null){
      if(arraylist_rl_zgcjqk.size()>0)
      {
        arraylist_rl_zgcjqk.clear();
      }
    }
  }
  /**
   * 初始化操作的触发类
   */
  class Init implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      hth = "2";
      retuUrl = data.getParameter("src");
      retuUrl = retuUrl!= null ? retuUrl.trim() : retuUrl;
      HttpServletRequest request = data.getRequest();
      //初始化查询项目和内容
      RowMap row = fixedQuery.getSearchRow();
      row.clear();
      //初始化时清空数据集user.getHandleDeptWhereValue("deptid", "czyid")

      deptid=data.getParameter("deptid");//2004-2-18 在初始化类中添加了获取部门ID的跳转语句,以接收从部门信息处传递的值!
      String deptids = user.getHandleDeptValue("deptid");//部门权限列表

      String sql=combineSQL(MASTER_SQL,"?",new String[]{""});
      if(deptid!=null&&!deptid.equals(""))
      {
        if(deptids.indexOf(deptid)<0)
        {
          data.setMessage(showJavaScript("alert('没有这个部门权限!')"));
        sql=combineSQL(MASTER_SQL,"?",new String[]{" AND deptid=''"});
        }
        else
          sql=combineSQL(MASTER_SQL,"?",new String[]{" AND deptid="+deptid});
        row.put("deptid",deptid);//推到查询中
      }
      else
        //sql=combineSQL(MASTER_SQL,"?",new String[]{" AND "+user.getHandleDeptWhereValue("deptid", "czyid")});
        sql=combineSQL(MASTER_SQL,"?",new String[]{" AND "+user.getHandleDeptValue("deptid")});
      if(dsMasterList.isOpen() && dsMasterList.getRowCount() > 0)
        dsMasterList.empty();
      dsMasterList.setQueryString(sql);
      dsMasterList.setRowMax(null);
      data.setMessage(showJavaScript("showFixedQuery();"));
    }
  }
  /**
   * 主表添加或修改操作的触发类
   */
  class Master_Add_Edit implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      file = null;
      isMasterAdd = String.valueOf(ADD).equals(action);
      if(!isMasterAdd)
      {
        dsMasterList.goToRow(Integer.parseInt(data.getParameter("rownum")));
        masterRow = dsMasterList.getInternalRow();
        personid = dsMasterList.getValue("personid");

      }
      if(isMasterAdd){

        String code = dataSetProvider.getSequence("SELECT pck_base.fieldNextCode('emp','bm','','',6) from dual");
        m_RowInfo.clear();
        m_RowInfo.put("bm", code);
        m_RowInfo.put("isDeformity", "0");
        initArrayList();
        //isMasterAdd=false;
      }

      dsMasterTable.setQueryString(isMasterAdd?MASTER_STRUT_SQL:combineSQL(MASTER_EDIT_SQL,"?",new String[]{personid}));
      if(!dsMasterTable.isOpen())
        dsMasterTable.openDataSet();
      else
        dsMasterTable.refresh();

      if(isMasterAdd){
        initRowInfo(false, isMasterAdd, true);
        initRowInfo(true, isMasterAdd, true);
      }else
      {
        initRowInfo(true, isMasterAdd, true);
        initRowInfo(false, isMasterAdd, true);
      }
      //打开从表
      openDetailTable();
      //data.setMessage(showJavaScript("toDetail();"));
    }
  }
  /**
   * 主表保存操作的触发类
   */
  class Master_Post implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      //把网页中的从表的信息推入ArrayList中
      putDetailInfo(data.getRequest());
      //得到主表的数据集
      EngineDataSet ds = getMaterTable();
      //所要修改或查询的主表的一条记录信息
      RowMap rowInfo = getMasterRowinfo();
      String bm = rowInfo.get("bm");
      if(!bm.trim().equals(""))
      {
        String count = dataSetProvider.getSequence("SELECT COUNT(*) FROM emp WHERE  emp.isdelete<>1 AND bm="+bm);
        if(!count.equals("0")&&isMasterAdd)
        {
          data.setMessage(showJavaScript("alert('此员工编码已被使用,请重新输入!')"));
          return;
        }
      }
      else
      {
        bm = dataSetProvider.getSequence("SELECT pck_base.fieldNextCode('emp','bm','','',6) from dual");
      }
      //校验表单数据
      String temp = checkMasterInfo();//检验主表
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
      //得到主表主键值
      //String personid = null;
      if(isMasterAdd){
        ds.insertRow(false);
        personid =  dataSetProvider.getSequence("s_emp");
        ds.setValue("isdelete", "0");
        ds.setValue("isuse", "0");
        ds.setValue("isshow", "1");
        //ds.setValue("isoff", "0");
        //String bm = dataSetProvider.getSequence("SELECT pck_base.fieldNextCode('emp','bm','','',6) from dual");
        ds.setValue("personid", personid);
        ds.setValue("username", "YG"+bm);
        String code = dataSetProvider.getSequence("SELECT pck_base.fieldNextCode('emp','bm','','',6) from dual");
        ds.setValue("bm", bm);
      }
      //保存上传的文件
      if(file != null){
        file.saveAs(ds, "photo");
        dsMasterTable.setValue("fileformat", file.getContentType());
        file = null;
      }
      //保存从表的数据
      RowMap detailrow = null;
      //家庭情况
      EngineDataSet detail_rl_zgjtqk = getzgjtqkTable();
      detail_rl_zgjtqk.first();
      for(int i=0; i<detail_rl_zgjtqk.getRowCount(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgjtqk.get(i);
        //新添的记录
        if(isMasterAdd)
          detail_rl_zgjtqk.setValue("personid", personid);
        detail_rl_zgjtqk.setValue("cf", detailrow.get("cf"));//
        detail_rl_zgjtqk.setValue("xm", detailrow.get("xm"));
        detail_rl_zgjtqk.setValue("zy", detailrow.get("zy"));//
        detail_rl_zgjtqk.setValue("csrq", detailrow.get("csrq"));//
        detail_rl_zgjtqk.setValue("bz", detailrow.get("bz"));//备注
        detail_rl_zgjtqk.next();
      }
    /*保存职工教育*/
      EngineDataSet detail_rl_zgjyqk = getZgjyqkTable();
      detail_rl_zgjyqk.first();
      for(int i=0; i<detail_rl_zgjyqk.getRowCount(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgjyqk.get(i);
        //新添的记录
        if(isMasterAdd)
          detail_rl_zgjyqk.setValue("personid", personid);
        detail_rl_zgjyqk.setValue("byxx", detailrow.get("byxx"));//
        detail_rl_zgjyqk.setValue("sxzy", detailrow.get("sxzy"));
        detail_rl_zgjyqk.setValue("zmr", detailrow.get("zmr"));//
        detail_rl_zgjyqk.setValue("kssj", detailrow.get("kssj"));//
        detail_rl_zgjyqk.setValue("jssj", detailrow.get("jssj"));//jssj
        detail_rl_zgjyqk.setValue("bz", detailrow.get("bz"));//备注
        detail_rl_zgjyqk.next();
      }
    /*保存职工工作经历*/
      EngineDataSet detail_rl_zggzjl = getZggzjlTable();
      detail_rl_zggzjl.first();
      for(int i=0; i<detail_rl_zggzjl.getRowCount(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zggzjl.get(i);
        //新添的记录
        if(isMasterAdd)
          detail_rl_zggzjl.setValue("personid", personid);
        detail_rl_zggzjl.setValue("gzdw", detailrow.get("gzdw"));//
        detail_rl_zggzjl.setValue("zw", detailrow.get("zw"));
        detail_rl_zggzjl.setValue("kssj", detailrow.get("kssj"));//
        detail_rl_zggzjl.setValue("jssj", detailrow.get("jssj"));//jssj
        detail_rl_zggzjl.setValue("bz", detailrow.get("bz"));//备注
        detail_rl_zggzjl.next();
      }
    /*保存职工培训情况*/
      EngineDataSet detail_rl_zgpxqk = getzgpxqkTable();
      detail_rl_zgpxqk.first();
      for(int i=0; i<detail_rl_zgpxqk.getRowCount(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgpxqk.get(i);
        //新添的记录
        if(isMasterAdd)
          detail_rl_zgpxqk.setValue("personid", personid);
        detail_rl_zgpxqk.setValue("pxxm", detailrow.get("pxxm"));//
        detail_rl_zgpxqk.setValue("zzjg", detailrow.get("zzjg"));
        detail_rl_zgpxqk.setValue("kssj", detailrow.get("kssj"));//
        detail_rl_zgpxqk.setValue("jssj", detailrow.get("jssj"));//jssj
        detail_rl_zgpxqk.setValue("bz", detailrow.get("bz"));//备注
        detail_rl_zgpxqk.next();
      }
    /*保存职工奖惩情况*/
      EngineDataSet detail_rl_zgjcqk = getzgjcqkTable();
      detail_rl_zgjcqk.first();
      for(int i=0; i<detail_rl_zgjcqk.getRowCount(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgjcqk.get(i);
        //新添的记录
        if(isMasterAdd)
          detail_rl_zgjcqk.setValue("personid", personid);
        detail_rl_zgjcqk.setValue("jcjg", detailrow.get("jcjg"));//
        detail_rl_zgjcqk.setValue("yy", detailrow.get("yy"));
        detail_rl_zgjcqk.setValue("rq", detailrow.get("rq"));//
        detail_rl_zgjcqk.setValue("bz", detailrow.get("bz"));//备注
        detail_rl_zgjcqk.next();
      }
    /*保存职工特长爱好*/
      EngineDataSet detail_rl_zgtcah = getzgtcahTable();
      detail_rl_zgtcah.first();
      for(int i=0; i<detail_rl_zgtcah.getRowCount(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgtcah.get(i);
        //新添的记录
        if(isMasterAdd)
          detail_rl_zgtcah.setValue("personid", personid);
        detail_rl_zgtcah.setValue("tcah", detailrow.get("tcah"));//
        detail_rl_zgtcah.setValue("djzs", detailrow.get("djzs"));
        detail_rl_zgtcah.setValue("fzjg", detailrow.get("fzjg"));//
        detail_rl_zgtcah.setValue("fzrq", detailrow.get("fzrq"));//
        detail_rl_zgtcah.setValue("bz", detailrow.get("bz"));//备注
        detail_rl_zgtcah.next();
      }
    /*保存职工保险情况*/
      EngineDataSet detail_rl_zgbxqk = getzgbxqkTable();
      detail_rl_zgbxqk.first();
      for(int i=0; i<detail_rl_zgbxqk.getRowCount(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgbxqk.get(i);
        //新添的记录
        if(isMasterAdd)
          detail_rl_zgbxqk.setValue("personid", personid);//
        detail_rl_zgbxqk.setValue("xz", detailrow.get("xz"));//
        detail_rl_zgbxqk.setValue("bxgs", detailrow.get("bxgs"));//
        detail_rl_zgbxqk.setValue("bxrq", detailrow.get("bxrq"));//
        detail_rl_zgbxqk.setValue("shsj", detailrow.get("shsj"));//
        detail_rl_zgbxqk.setValue("ylfy", detailrow.get("ylfy"));//
        detail_rl_zgbxqk.setValue("lpje", detailrow.get("lpje"));//
        detail_rl_zgbxqk.setValue("ce", detailrow.get("ce"));//
        detail_rl_zgbxqk.setValue("shbzts", detailrow.get("shbzts"));//
        detail_rl_zgbxqk.setValue("bxe", detailrow.get("bxe"));//
        detail_rl_zgbxqk.setValue("bz", detailrow.get("bz"));//备注
        detail_rl_zgbxqk.next();
      }
    /*保存残疾情况 */
      EngineDataSet detail_rl_zgcjqk = getzgcjqkTable();
      detail_rl_zgcjqk.first();
      for(int i=0; i<detail_rl_zgcjqk.getRowCount(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgcjqk.get(i);
        //新添的记录
        if(isMasterAdd)
          detail_rl_zgbxqk.setValue("personid", personid);
        detail_rl_zgcjqk.setValue("cjrzh", detailrow.get("cjrzh"));//
        detail_rl_zgcjqk.setValue("azsj", detailrow.get("azsj"));
        detail_rl_zgcjqk.setValue("gzgw", detailrow.get("gzgw"));//
        detail_rl_zgcjqk.setValue("cjlb", detailrow.get("cjlb"));//
        detail_rl_zgcjqk.setValue("bdr", detailrow.get("bdr"));//
        detail_rl_zgcjqk.setValue("bz", detailrow.get("bz"));//备注
        detail_rl_zgcjqk.next();
      }
      /*保存职工其他*/
      EngineDataSet detail_rl_zgqtxx = getzgqtxxTable();
      detail_rl_zgqtxx.first();
      for(int i=0; i<detail_rl_zgqtxx.getRowCount(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgqtxx.get(i);
        //新添的记录
        if(isMasterAdd)
          detail_rl_zgqtxx.setValue("personid", personid);
        detail_rl_zgqtxx.setValue("qdrq", detailrow.get("qdrq"));//
        detail_rl_zgqtxx.setValue("hth", detailrow.get("hth"));
        detail_rl_zgqtxx.setValue("syrq", detailrow.get("syrq"));//
        detail_rl_zgqtxx.setValue("htqx", detailrow.get("htqx"));//
        detail_rl_zgqtxx.setValue("rzrq", detailrow.get("rzrq"));//
        detail_rl_zgqtxx.setValue("htqx", detailrow.get("htqx"));//
        detail_rl_zgqtxx.setValue("fjh", detailrow.get("fjh"));//
        detail_rl_zgqtxx.setValue("gh", detailrow.get("gh"));//
        detail_rl_zgqtxx.setValue("hk", detailrow.get("hk"));//
        detail_rl_zgqtxx.setValue("zzz", detailrow.get("zzz"));//备注
        detail_rl_zgqtxx.next();
      }
      /*保存职工有关证件*/

      EngineDataSet detail_rl_zgygzj = getzgygzjTable();
      detail_rl_zgygzj.first();
      for(int i=0; i<detail_rl_zgygzj.getRowCount(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgygzj.get(i);
        //新添的记录
        String kk=detailrow.get("certname");
        if(isMasterAdd)
          detail_rl_zgygzj.setValue("personid", personid);
        detail_rl_zgygzj.setValue("certname", detailrow.get("certname"));//证件名称
        detail_rl_zgygzj.setValue("certno", detailrow.get("certno"));//证件编号
        detail_rl_zgygzj.setValue("startdate", detailrow.get("startdate"));//开始日期
        detail_rl_zgygzj.setValue("enddate", detailrow.get("enddate"));//结束日期

        detail_rl_zgygzj.next();
      }
      //保存主表数据
      ds.setValue("bm", bm);//
      ds.setValue("xm", rowInfo.get("xm"));//
      ds.setValue("deptid", rowInfo.get("deptid"));//
      ds.setValue("lb", rowInfo.get("lb"));//
      ds.setValue("zw", rowInfo.get("zw"));//
      ds.setValue("zc", rowInfo.get("zc"));//
      ds.setValue("sex", rowInfo.get("sex"));//
      ds.setValue("email", rowInfo.get("email"));//
      ds.setValue("mobile", rowInfo.get("mobile"));//
      ds.setValue("mz", rowInfo.get("mz"));//
      ds.setValue("sfzhm", rowInfo.get("sfzhm"));//
      ds.setValue("isDeformity", rowInfo.get("isDeformity"));//
      ds.setValue("phone", rowInfo.get("phone"));//
      ds.setValue("zzmm", rowInfo.get("zzmm"));//
      ds.setValue("study", rowInfo.get("study"));//
      ds.setValue("date_born", rowInfo.get("date_born"));//
      ds.setValue("date_in", rowInfo.get("date_in"));//
      ds.setValue("jg", rowInfo.get("jg"));//
      ds.setValue("jb", rowInfo.get("jb"));//级别保存
      ds.setValue("addr", rowInfo.get("addr"));//
      ds.setValue("gh", rowInfo.get("gh"));//
      ds.setValue("bz", rowInfo.get("bz"));//

      Date ed = new Date();
      String CZRQ =  new SimpleDateFormat("yyyy-MM-dd").format(ed);
      ds.setValue("CZYID", czyid);
      ds.setValue("CZRQ", CZRQ);

      ds.post();
      ds.saveDataSets(new EngineDataSet[]{ds, detail_rl_zgjtqk,detail_rl_zgjyqk,detail_rl_zggzjl,detail_rl_zgpxqk,detail_rl_zgjcqk,detail_rl_zgbxqk,detail_rl_zgtcah,detail_rl_zgqtxx,detail_rl_zgcjqk,detail_rl_zgygzj}, null);
      //if(!dsMasterTable.isAssignedNull("photo"))
      //ds.getInputStream("photo").reset();
      //刷新lookup的数据集，保持数据的同步.入参是相应的lookup名称
      LookupBeanFacade.refreshLookup(SysConstant.BEAN_PERSON);
      if(String.valueOf(POST_CONTINUE).equals(action))
      {
        isMasterAdd = true;
        initRowInfo(true, true, true);//重新初始化从表的各行信息

        String code = dataSetProvider.getSequence("SELECT pck_base.fieldNextCode('emp','bm','','',6) from dual");
        m_RowInfo.clear();
        m_RowInfo.put("bm", code);
        initArrayList();
        initRowInfo(false, false, true);//重新初始化从表的各行信息
      }
      else if(String.valueOf(POST).equals(action)){
        isMasterAdd = false;
      }
      else if(String.valueOf(OPERATE_A).equals(action))
        data.setMessage(showJavaScript("backList();"));
    }
    /**
     * 校验从表表单信息从表输入的信息的正确性
     * @return null 表示没有信息
     */
    public String checkDetailInfo()
    {
      String temp = null;
      RowMap detailrow = null;
      //职工家庭情况
      for(int i=0; i<arraylist_rl_zgjtqk.size(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgjtqk.get(i);
        temp = detailrow.get("xm");
        if(temp.equals(""))
          return showJavaScript("alert('姓名不能为空!');SetActiveTab(INFO_EX,'INFO_EX_0');");
        temp = detailrow.get("csrq");
        if(temp.length() > 0 && !isDate(temp))
          return showJavaScript("alert('家庭情况的出生日期非法！');SetActiveTab(INFO_EX,'INFO_EX_0');");
      }
      //职工教育情况
      for(int i=0; i<arraylist_rl_zgjyqk.size(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgjyqk.get(i);
        temp = detailrow.get("byxx");
        if(temp.equals(""))
          return showJavaScript("alert('毕业学校不能为空!');");
        temp = detailrow.get("sxzy");
        if(temp.equals(""))
          return showJavaScript("alert('所学专业不能为空!');SetActiveTab(INFO_EX,'INFO_EX_1')");
        temp = detailrow.get("kssj");
        if(temp.length() > 0 && !isDate(temp))
          return showJavaScript("alert('教育情况的开始日期非法！');SetActiveTab(INFO_EX,'INFO_EX_1')");
        temp = detailrow.get("jssj");
        if(temp.length() > 0 && !isDate(temp))
          return showJavaScript("alert('教育情况的结束日期非法！');SetActiveTab(INFO_EX,'INFO_EX_1')");
      }
      //职工工作经历
      for(int i=0; i<arraylist_rl_zggzjl.size(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zggzjl.get(i);
        temp = detailrow.get("gzdw");
        if(temp.equals(""))
          return showJavaScript("alert('工作经历的工作单位不能为空!');SetActiveTab(INFO_EX,'INFO_EX_2');");
        temp = detailrow.get("kssj");
        if(temp.length() > 0 && !isDate(temp))
          return showJavaScript("alert('工作经历的非法开始日期！');SetActiveTab(INFO_EX,'INFO_EX_2');");
        temp = detailrow.get("jssj");
        if(temp.length() > 0 && !isDate(temp))
          return showJavaScript("alert('工作经历的非法结束日期！');SetActiveTab(INFO_EX,'INFO_EX_2');");
      }
      //职工培训情况
      for(int i=0; i<arraylist_rl_zgpxqk.size(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgpxqk.get(i);
        temp = detailrow.get("pxxm");
        if(temp.equals(""))
          return showJavaScript("alert('培训项目不能为空!');SetActiveTab(INFO_EX,'INFO_EX_3');");
        temp = detailrow.get("zzjg");
        if(temp.equals(""))
          return showJavaScript("alert('培训机构不能为空!');SetActiveTab(INFO_EX,'INFO_EX_3');");
        temp = detailrow.get("kssj");
        if(temp.length() > 0 && !isDate(temp))
          return showJavaScript("alert('培训经历的非法开始日期！');SetActiveTab(INFO_EX,'INFO_EX_3');");
        temp = detailrow.get("jssj");
        if(temp.length() > 0 && !isDate(temp))
          return showJavaScript("alert('培训经历的非法结束日期！');SetActiveTab(INFO_EX,'INFO_EX_3');");
      }
      //职工奖惩情况
      for(int i=0; i<arraylist_rl_zgjcqk.size(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgjcqk.get(i);
        temp = detailrow.get("jcjg");
        if(temp.equals(""))
          return showJavaScript("alert('奖惩结果不能为空!');SetActiveTab(INFO_EX,'INFO_EX_4');");
        temp = detailrow.get("yy");
        if(temp.equals(""))
          return showJavaScript("alert('奖惩愿因不能为空!');SetActiveTab(INFO_EX,'INFO_EX_4');");
        temp = detailrow.get("rq");
        if(temp.length() > 0 && !isDate(temp))
          return showJavaScript("alert('奖惩日期为非法日期！');SetActiveTab(INFO_EX,'INFO_EX_4');");
      }



      //职工特长爱好
      for(int i=0; i<arraylist_rl_zgtcah.size(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgtcah.get(i);
        temp = detailrow.get("tcah");
        if(temp.equals(""))
          return showJavaScript("alert('特长/爱好不能为空!');SetActiveTab(INFO_EX,'INFO_EX_5');");
        temp = detailrow.get("fzrq");
        if(temp.length() > 0 && !isDate(temp))
          return showJavaScript("alert('发证日期为非法日期！');SetActiveTab(INFO_EX,'INFO_EX_5');");
      }
      //职工残疾情况
      /***
      for(int i=0; i<arraylist_rl_zgcjqk.size(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgcjqk.get(i);
        temp = detailrow.get("cjrzh");
        if(temp.equals(""))
          return showJavaScript("alert('残疾人证号!');SetActiveTab(INFO_EX,'INFO_EX_10');");
        temp = detailrow.get("cjlb");
        if(temp.equals(""))
          return showJavaScript("alert('残疾类别!');SetActiveTab(INFO_EX,'INFO_EX_10');");
        temp = detailrow.get("azsj");
        if(temp.length() > 0 && !isDate(temp))
          return showJavaScript("alert('安置时间为非法日期！');SetActiveTab(INFO_EX,'INFO_EX_10');");
      }
      ***/
     //职工保险情况
      for(int i=0; i<arraylist_rl_zgbxqk.size(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgbxqk.get(i);
        temp = detailrow.get("xz");
        if(temp.equals(""))
          return showJavaScript("alert('险种不能为空!');SetActiveTab(INFO_EX,'INFO_EX_8');");
        temp = detailrow.get("bxgs");
        if(temp.equals(""))
          return showJavaScript("alert('承保公司不能为空!');SetActiveTab(INFO_EX,'INFO_EX_8');");
        temp = detailrow.get("bxe");
        if(temp.equals(""))
          return showJavaScript("alert('金额不能为空!');SetActiveTab(INFO_EX,'INFO_EX_8');");
        if((temp =checkNumber(temp,"金额输入错误,请输入数字!")) !=null)
          return showJavaScript("alert('金额输入错误,请输入数字!');SetActiveTab(INFO_EX,'INFO_EX_8');");
        temp = detailrow.get("bxrq");
        if(temp.equals(""))
          return showJavaScript("alert('保险日期不能为空!');SetActiveTab(INFO_EX,'INFO_EX_8');");
        if(!isDate(temp))
          return showJavaScript("alert('保险日期为非法日期！');SetActiveTab(INFO_EX,'INFO_EX_8');");
      }






      //职工有关证件
      for(int i=0; i<arraylist_rl_zgygzj.size(); i++)
      {
        detailrow = (RowMap)arraylist_rl_zgygzj.get(i);
        String temp1=null;
        String temp2=null;
        temp1 = detailrow.get("startdate");
        if(temp1.length() > 0 && !isDate(temp1))
          return showJavaScript("alert('开始日期非法！');SetActiveTab(INFO_EX,'INFO_EX_10')");
        temp2 = detailrow.get("enddate");
        if(temp2.length() > 0 && !isDate(temp2))
          return showJavaScript("alert('结束日期非法！');SetActiveTab(INFO_EX,'INFO_EX_10')");
        if(temp1.compareTo(temp2)>0)
          return showJavaScript("SetActiveTab(INFO_EX,'INFO_EX_10');alert('开始日期不能大于结束日期！')");
      }
      return null;
    }

    /**
     * 校验主表表表单信息从表输入的信息的正确性
     * @return null 表示没有信息,校验通过
     */
    private String checkMasterInfo() throws Exception
    {
      RowMap rowInfo = getMasterRowinfo();
      String operate = rowInfo.get("operate");
      String temp = rowInfo.get("xm");
      String bb=rowInfo.get("sfzhm");
      String personid=rowInfo.get("personid");
      String temp1=temp;
      if(temp.equals(""))
        return showJavaScript("alert('姓名不能为空！');");
      temp = rowInfo.get("deptid");
      if(temp.equals(""))
        return showJavaScript("alert('部门不能为空！');");
      temp = rowInfo.get("bz");
      if(temp.getBytes().length > getMaterTable().getColumn("bz").getPrecision())
        return showJavaScript("alert('您输入的备注的内容太长了！');");

      String count2= "0";
      if(isMasterAdd)
      {
        count2  = dataSetProvider.getSequence("SELECT COUNT(*)  FROM emp t WHERE t.isdelete<>1 and t.sfzhm='"+bb+"'");
      }
      else
      {
        count2  = dataSetProvider.getSequence("SELECT COUNT(*)  FROM emp t WHERE t.isdelete<>1 and  t.sfzhm='"+bb+"' and t.personid<>'"+personid+"'");
      }
      if(!count2.equals("0"))
        return showJavaScript("alert('该身份证号码已经存在！');");

      if(!operate.equals(OPERATE_A))
      {
        String count= "0";
        count  = dataSetProvider.getSequence("SELECT COUNT(*)  FROM emp t WHERE t.isdelete<>1 AND t.xm='"+temp1+"'" );
        if(!count.equals("0")&&isMasterAdd)
          return showJavaScript("if(confirm('该名称已经存在，是否还要保存！')) sumitForm("+OPERATE_A+",-1)");
      }
      return null;
    }
  }
  /**
   * 离职员工是否再显示在业务数据中
   */
  class Master_Show implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      EngineDataSet ds = getMaterTable();
      String rownum=data.getRequest().getParameter("rownum");
      ds.goToRow(Integer.parseInt(rownum));
      if(action.equals(String.valueOf(OPERATE_HIDDEN)))
      {
        ds.setValue("isshow","0");
      }
      else
      {
        ds.setValue("isshow","1");
      }
      ds.post();
      ds.saveChanges();
      ds.refresh();
      LookupBeanFacade.refreshLookup(SysConstant.BEAN_PERSON);
    }
  }
  /**
   * 主表删除操作
   */
  class Master_Delete implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      EngineDataSet ds = getMaterTable();
      if(!action.equals(String.valueOf(DEL)))
      {
        if(isMasterAdd){
          data.setMessage(showJavaScript("backList();"));
          return;
        }
        //dsMasterTable.goToInternalRow(masterRow);
      }
      //else
      //{
      //String rownum=data.getRequest().getParameter("rownum");
      //ds.goToRow(Integer.parseInt(rownum));
      //}
      ds.setValue("isDelete","1");

      Date ed = new Date();
      String CZRQ =  new SimpleDateFormat("yyyy-MM-dd").format(ed);
      ds.setValue("CZYID", czyid);
      ds.setValue("CZRQ", CZRQ);

      ds.post();
      ds.saveChanges();
      ds.refresh();
      if(action.equals(String.valueOf(DELETE_RETURN)))
      {
        data.setMessage(showJavaScript("backList();"));
      }
      //s.saveDataSets(new EngineDataSet[]{ds, dsrl_zgjtqk,dsrl_zgjyqk,dsrl_zggzjl,dsrl_zgpxqk,dsrl_zgjcqk,dsrl_zgtcah,dsrl_zgbxqk,dsrl_zgxxbd,dsrl_zgqtxx}, null);
      //d_RowInfos.clear();

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

      String deptids = user.getHandleDeptValue("deptid");//部门权限列表
      if(deptid!=null&&!deptid.equals(""))
      {
        if(deptids.indexOf(deptid)<0)
        {
          data.setMessage(showJavaScript("alert('没有这个部门权限!')"));
          SQL=SQL+" AND deptid=''";
        }else
          SQL=SQL+" AND deptid="+deptid;
      }
      else
        SQL=SQL+" AND "+user.getHandleDeptValue();
      hth = data.getRequest().getParameter("hth");
      if(hth.equals("1"))
        SQL = SQL+" AND personid in(select personid from VW_EMPLOYEE_HT where hth is not null) ";
      else if(hth.equals("0"))
        SQL = SQL+" AND personid in(select personid from VW_EMPLOYEE_HT where hth is  null) ";

      //.getHandleDeptWhereValue("deptid", "czyid");
      /*
      SQL = combineSQL(SEARCH_SQL, "?", new String[]{SQL});
       if(!dsSearchTable.getQueryString().equals(SQL))
      {
        dsSearchTable.setQueryString(SQL);
        dsSearchTable.setRowMax(null);
      }
      dsSearchTable.refresh();
      StringBuffer sb = new StringBuffer();
      ArrayList al = new ArrayList();
      String personids="";
      dsSearchTable.first();
      for(int i=0;i<dsSearchTable.getRowCount();i++)
      {
        String personid = dsSearchTable.getValue("personid");
        if(personid!=null&&!personid.equals(""))
          if(!al.contains(personid))
          al.add(personid);
          dsSearchTable.next();
      }
      if(al.size()==0)
        personids="0";
      else
      {
        for(int j=0;j<al.size();j++)
          sb.append(al.get(j)+",");
        personids=sb.append("0").toString();
      }
      */

      if(!dsMasterList.isOpen())
        dsMasterList.open();
      // SQL = combineSQL(MASTER_SQL, "?", new String[]{" AND personid IN("+personids+") "});
      SQL = combineSQL(MASTER_SQLC, "?", new String[]{SQL});
      if(!dsMasterList.getQueryString().equals(SQL))
      {
        dsMasterList.setQueryString(SQL);
        dsMasterList.setRowMax(null);
      }
    }
    /**
     * 初始化查询的各个列
     * @param request web请求对象
     */
    private void initQueryItem(HttpServletRequest request)
    {
      if(isInitQuery)
        return;
      EngineDataSet master = dsMasterList;
      if(!master.isOpen())
        master.open();
      //初始化固定的查询项目
      fixedQuery = new QueryFixedItem();
      Column personid = new Column("personid", "personid", Variant.DATE);
      fixedQuery.addShowColumn("", new QueryColumn[]{
        new QueryColumn(master.getColumn("bm"), null, null, null, null, "like"),
        new QueryColumn(master.getColumn("xm"), null, null, null, null, "like"),
        new QueryColumn(master.getColumn("deptid"), null, null, null, null, "="),
        new QueryColumn(master.getColumn("isdelete"), null, null, null, null, "="),
        //new QueryColumn(master.getColumn("personid"), "VW_EMPLOYEE_ht", "personid", "hth", "hth", "="),
        new QueryColumn(master.getColumn("date_born"), null, null, null, "a", ">="),//
        new QueryColumn(master.getColumn("date_born"), null, null, null, "b", "<="),//
        new QueryColumn(master.getColumn("date_in"), null, null, null, "a", ">="),//
        new QueryColumn(master.getColumn("date_in"), null, null, null, "b", "<="),//
        new QueryColumn(master.getColumn("zw"), null, null, null, null, "="),
        new QueryColumn(master.getColumn("jb"), null, null, null, null, "="),
        new QueryColumn(master.getColumn("study"), null, null, null, null, "="),
        new QueryColumn(personid, "VW_EMPLOYEE_bx", "personid", "bxrq", "a", ">="),//
        new QueryColumn(personid, "VW_EMPLOYEE_bx", "personid", "bxrq", "b", "<="),//
        new QueryColumn(master.getColumn("sex"), null, null, null, null, "="),
        new QueryColumn(master.getColumn("sex"), null, null, null, null, "="),
        new QueryColumn(master.getColumn("sfzhm"), null, null, null, null, "like"),
      });
      isInitQuery = true;
    }
  }
  /**
   * 0号
   * 职工家庭情况
   *
   * */
  class Rl_zgjtqk_adddel  implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      if(action.equals(ZGJTQK_ADD))
      {
        putDetailInfo(data.getRequest());

        dsrl_zgjtqk.insertRow(false);
        dsrl_zgjtqk.setValue("personid", personid);
        dsrl_zgjtqk.post();
        RowMap zg_Temp_Row = new RowMap(dsrl_zgjtqk);
        arraylist_rl_zgjtqk.add(zg_Temp_Row);
      }
      if(action.equals(ZGJTQK_DEL))
      {
        putDetailInfo(data.getRequest());
        int rownum=Integer.parseInt(data.getRequest().getParameter("rownum"));
        arraylist_rl_zgjtqk.remove(rownum);
        dsrl_zgjtqk.goToRow(rownum);
        dsrl_zgjtqk.deleteRow();
      }
      activetab="SetActiveTab(INFO_EX,'INFO_EX_0')";
      data.setMessage(showJavaScript(activetab));
    }
  }
  /**
   *
   * 职工教育情况
   * */
  class  Rl_zgjyqk_adddel implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      if(action.equals(ZGJYQK_ADD))
      {
        putDetailInfo(data.getRequest());

        dsrl_zgjyqk.insertRow(false);
        dsrl_zgjyqk.setValue("personid", personid);
        dsrl_zgjyqk.post();
        RowMap zg_Temp_Row = new RowMap(dsrl_zgjyqk);
        arraylist_rl_zgjyqk.add(zg_Temp_Row);
      }
      if(action.equals(ZGJYQK_DEL))
      {
        putDetailInfo(data.getRequest());
        int rownum=Integer.parseInt(data.getRequest().getParameter("rownum"));
        arraylist_rl_zgjyqk.remove(rownum);
        dsrl_zgjyqk.goToRow(rownum);
        dsrl_zgjyqk.deleteRow();
      }
      activetab="SetActiveTab(INFO_EX,'INFO_EX_1')";
      data.setMessage(showJavaScript(activetab));
    }
  }
  /**
   *职工工作经历
   *
   **/
  class Rl_zggzjl_adddel  implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      if(action.equals(ZGGZJL_ADD))
      {
        putDetailInfo(data.getRequest());

        dsrl_zggzjl.insertRow(false);
        dsrl_zggzjl.setValue("personid", personid);
        dsrl_zggzjl.post();
        RowMap zg_Temp_Row = new RowMap(dsrl_zggzjl);
        arraylist_rl_zggzjl.add(zg_Temp_Row);
      }
      if(action.equals(ZGGZJL_DEL))
      {
        putDetailInfo(data.getRequest());
        int rownum=Integer.parseInt(data.getRequest().getParameter("rownum"));
        arraylist_rl_zggzjl.remove(rownum);
        dsrl_zggzjl.goToRow(rownum);
        dsrl_zggzjl.deleteRow();
      }
      activetab="SetActiveTab(INFO_EX,'INFO_EX_2')";
      data.setMessage(showJavaScript(activetab));
    }
  }
  /**
   *
   *职工培训情况
   *
   * */
  class Rl_zgpxqk_adddel  implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      if(action.equals(ZGPXQK_ADD))
      {
        putDetailInfo(data.getRequest());

        dsrl_zgpxqk.insertRow(false);
        dsrl_zgpxqk.setValue("personid", personid);
        dsrl_zgpxqk.post();
        RowMap zg_Temp_Row = new RowMap(dsrl_zgpxqk);
        arraylist_rl_zgpxqk.add(zg_Temp_Row);
      }
      if(action.equals(ZGPXQK_DEL))
      {
        putDetailInfo(data.getRequest());
        int rownum=Integer.parseInt(data.getRequest().getParameter("rownum"));
        arraylist_rl_zgpxqk.remove(rownum);
        dsrl_zgpxqk.goToRow(rownum);
        dsrl_zgpxqk.deleteRow();
      }
      activetab="SetActiveTab(INFO_EX,'INFO_EX_3')";
      data.setMessage(showJavaScript(activetab));
    }
  }
  /**
   *
   * 职工奖惩情况
   *
   * */
  class Rl_zgjcqk_adddel  implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      if(action.equals(ZGJCQK_ADD))
      {
        putDetailInfo(data.getRequest());

        dsrl_zgjcqk.insertRow(false);
        dsrl_zgjcqk.setValue("personid", personid);
        dsrl_zgjcqk.post();
        RowMap zg_Temp_Row = new RowMap(dsrl_zgjcqk);
        arraylist_rl_zgjcqk.add(zg_Temp_Row);
      }
      if(action.equals(ZGJCQK_DEL))
      {
        putDetailInfo(data.getRequest());
        int rownum=Integer.parseInt(data.getRequest().getParameter("rownum"));
        arraylist_rl_zgjcqk.remove(rownum);
        dsrl_zgjcqk.goToRow(rownum);
        dsrl_zgjcqk.deleteRow();
      }
      activetab="SetActiveTab(INFO_EX,'INFO_EX_4')";
      data.setMessage(showJavaScript(activetab));
    }
  }
  /**
   * * 职工特长爱好
   * *
   * */
  class Rl_zgtcah_adddel  implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      if(action.equals(ZGTCAH_ADD))
      {
        putDetailInfo(data.getRequest());

        dsrl_zgtcah.insertRow(false);
        dsrl_zgtcah.setValue("personid", personid);
        dsrl_zgtcah.post();
        RowMap zg_Temp_Row = new RowMap(dsrl_zgtcah);
        arraylist_rl_zgtcah.add(zg_Temp_Row);
      }
      if(action.equals(ZGTCAH_DEL))
      {
        putDetailInfo(data.getRequest());
        int rownum=Integer.parseInt(data.getRequest().getParameter("rownum"));
        arraylist_rl_zgtcah.remove(rownum);
        dsrl_zgtcah.goToRow(rownum);
        dsrl_zgtcah.deleteRow();
      }
      activetab="SetActiveTab(INFO_EX,'INFO_EX_5')";
      data.setMessage(showJavaScript(activetab));
    }
  }
  /**
   *
   * 职工保险情况
   *
   * */
  class Rl_zgbxqk_adddel  implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      if(action.equals(ZGBXQK_ADD))
      {
        putDetailInfo(data.getRequest());

        dsrl_zgbxqk.insertRow(false);
        dsrl_zgbxqk.setValue("personid", personid);
        dsrl_zgbxqk.post();
        RowMap zg_Temp_Row = new RowMap(dsrl_zgbxqk);
        arraylist_rl_zgbxqk.add(zg_Temp_Row);
      }
      if(action.equals(ZGBXQK_DEL))
      {
        putDetailInfo(data.getRequest());
        int rownum=Integer.parseInt(data.getRequest().getParameter("rownum"));
        arraylist_rl_zgbxqk.remove(rownum);
        dsrl_zgbxqk.goToRow(rownum);
        dsrl_zgbxqk.deleteRow();
      }
      activetab="SetActiveTab(INFO_EX,'INFO_EX_8')";
      data.setMessage(showJavaScript(activetab));
    }
  }
  /**
   *
   * 职工其他信息
   *
   * */
  class Rl_zgqtxx_adddel  implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      if(action.equals(ZGQTXX_ADD))
      {
        putDetailInfo(data.getRequest());

        if(dsrl_zgqtxx.getRowCount()>0)
        {
          data.setMessage(showJavaScript("alert('只能有一行记录!');"));
          return;
        }
        dsrl_zgqtxx.insertRow(false);
        dsrl_zgqtxx.setValue("personid", personid);
        dsrl_zgqtxx.post();
        RowMap zg_Temp_Row = new RowMap(dsrl_zgqtxx);
        arraylist_rl_zgqtxx.add(zg_Temp_Row);
      }
      if(action.equals(ZGQTXX_DEL))
      {
        putDetailInfo(data.getRequest());
        int rownum=Integer.parseInt(data.getRequest().getParameter("rownum"));
        arraylist_rl_zgqtxx.remove(rownum);
        dsrl_zgqtxx.goToRow(rownum);
        dsrl_zgqtxx.deleteRow();
      }
      activetab="SetActiveTab(INFO_EX,'INFO_EX_9')";
      data.setMessage(showJavaScript(activetab));
    }
  }

  /**
   *职工有关证件
   */
  class Rl_zgygzj_adddel  implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      if(action.equals(ZGYGZJ_ADD))
      {
        putDetailInfo(data.getRequest());

        dsrl_zgygzj.insertRow(false);
        dsrl_zgygzj.setValue("personid", personid);
        dsrl_zgygzj.post();
        RowMap zg_Temp_Row = new RowMap(dsrl_zgygzj);
        arraylist_rl_zgygzj.add(zg_Temp_Row);
      }
      if(action.equals(ZGYGZJ_DEL))
      {
        putDetailInfo(data.getRequest());
        int rownum=Integer.parseInt(data.getRequest().getParameter("rownum"));
        arraylist_rl_zgygzj.remove(rownum);
        dsrl_zgygzj.goToRow(rownum);
        dsrl_zgygzj.deleteRow();
      }
      activetab="SetActiveTab(INFO_EX,'INFO_EX_10')";
      data.setMessage(showJavaScript(activetab));
    }
  }

  /**
   *残疾情况的触发操作 EFORMITY
   */
  class Defomity_Onchange  implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      putDetailInfo(data.getRequest());
    }
  }

  public final boolean isAdd(){
    return isMasterAdd;
  }

  public final void showPhoto(HttpServletRequest request, HttpServletResponse response)
      throws java.io.IOException
  {
    if(!dsMasterTable.isOpen())
      return;
    if(file == null && isMasterAdd)
      return;
    if(file != null){
      file.download(response, null);
    }
    else{
      String mime_type = dsMasterTable.getValue("fileformat");
      FileUpload upload = new FileUpload();
      upload.downloadField(response, dsMasterTable, "photo", mime_type, null);
    }
  }

  //上传图片
  class UploadPhoto implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      FileUpload upload = new FileUpload();
      //设置禁止上传的文件扩展名列表
      upload.setDeniedFilesList("jsp,do,ex");
      //设置最大上传文件的大小:5M
      upload.setMaxFileSize(5*1024*1024);
      //分析上传文件
      upload.upload(data.getRequest());
      //得到表单的输入框参数。不可用data.getRequest().getParameter("file_name")方法,这样是得不到的;
      //String file_name = upload.getRequest().getParameter("file_name");
      //得到第一个上传的文件
      file = upload.getFiles().getFile(0);
      //剥离父亲upload对象, 即剔除upload的引用
      file.leaveParent();
      data.setMessage(showJavaScript("hidewin();"));
    }
  }
  /**
   * 职工残疾情况
   */
  /*class Rl_zgcjqk_adddel  implements Obactioner
  {
    public void execute(String action, Obationable o, RunData data, Object arg) throws Exception
    {
      if(action.equals(ZGCJQK_ADD))
      {
        putDetailInfo(data.getRequest());
        if(!isMasterAdd)
          dsMasterTable.goToInternalRow(masterRow);
        String personid = dsMasterTable.getValue("personid");
        dsrl_zgcjqk.insertRow(false);
        dsrl_zgcjqk.setValue("personid", personid);
        //dsrl_zgcjqk.setValue("zgcjqkID", "-1");
        dsrl_zgcjqk.post();
        RowMap zg_Temp_Row = new RowMap(dsrl_zgcjqk);
        arraylist_rl_zgcjqk.add(zg_Temp_Row);
      }
      if(action.equals(ZGCJQK_DEL))
      {
        putDetailInfo(data.getRequest());
        int rownum=Integer.parseInt(data.getRequest().getParameter("rownum"));
        arraylist_rl_zgcjqk.remove(rownum);
        dsrl_zgcjqk.goToRow(rownum);
        dsrl_zgcjqk.deleteRow();
      }
      activetab="SetActiveTab(INFO_EX,'INFO_EX_10')";
      data.setMessage(showJavaScript(activetab));
    }
  }*/
}