<%--销售提单--%><%@ page contentType="text/html; charset=UTF-8" %><%@ include file="../pub/init.jsp"%>
<%@ page import="engine.dataset.*,engine.project.Operate,java.math.BigDecimal,engine.html.*,java.util.ArrayList"%>
<%!
  String op_add    = "op_add";
  String op_delete = "op_delete";
  String op_edit   = "op_edit";
  String op_search = "op_search";
  String op_approve ="op_approve";
%>
<%
  engine.erp.sale.xixing.B_DirectSell b_DirectSellBean = engine.erp.sale.xixing.B_DirectSell.getInstance(request);
  String pageCode = "directsell";
%>
<html>
<head>
<title></title>
<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../scripts/public.css" type="text/css">
</head>
<script language="javascript" src="../scripts/validate.js"></script>
<script language="javascript" src="../scripts/rowcontrol.js"></script>
<script language="javascript" src="../scripts/tabcontrol.js"></script>
<script language="javascript">
function sumitForm(oper, row)
{
  lockScreenToWait("处理中, 请稍候！");
  form1.rownum.value = row;
  form1.operate.value = oper;
  form1.submit();
}
function backList()
{
  location.href='directsell.jsp';
}
//打印
function ladingprint(tdid)
{
  location.href='../pub/pdfprint.jsp?operate=<%=Operate.PRINT_PRECISION%>&code=xs_lading_bill_print&tdid='+tdid;
}
//输入购货单位代码
function customerCodeSelect(obj)
{
  CustCodeChange(document.all['prod'], obj.form.name,'srcVar=dwdm&srcVar=dwtxid&srcVar=dwmc','fieldVar=dwdm&fieldVar=dwtxid&fieldVar=dwmc',obj.value);
}
//选择购货单位
function selectCustomer()
{
  CustSingleSelect('form1','srcVar=dwtxid&srcVar=dwmc&srcVar=dwdm','fieldVar=dwtxid&fieldVar=dwmc&fieldVar=dwdm',form1.dwtxid.value);
}
//输入购货单位名称
function customerNameSelect(obj)
{
  CustNameChange(document.all['prod'], obj.form.name,'srcVar=dwdm&srcVar=dwtxid&srcVar=dwmc','fieldVar=dwdm&fieldVar=dwtxid&fieldVar=dwmc',obj.value);
}
//运输单位
function TransportDmChange(obj, i)
{
    TransportCodeChange(document.all['prod'], obj.form.name,'srcVar=dwtxid_'+i+'&srcVar=dwdm_'+i+'&srcVar=dwmc_'+i,'fieldVar=dwtxid&fieldVar=dwdm&fieldVar=dwmc',obj.value);
}
function TransportName(obj, i)
{
    TransportNameChange(document.all['prod'], obj.form.name,'srcVar=dwtxid_'+i+'&srcVar=dwdm_'+i+'&srcVar=dwmc_'+i,'fieldVar=dwtxid&fieldVar=dwdm&fieldVar=dwmc',obj.value);
}
//提单日期变化--引起回款日期变化
function tdrqOnchange()
{
  checkDate(document.form1.tdrq);
  if(document.form1.hkts.value=="")
    return;
  else
  {
    document.form1.hkrq.value=addDate(document.form1.tdrq.value,parseFloat(document.form1.hkts.value));
  }
}
function selectTdrq()
{
  selectDate(document.form1.tdrq);
}
//回款天数变化--引起回款日期变化
function hktsOnchange()
{
  if(isNaN(document.form1.hkts.value)){
    alert("输入数据非法!");
    document.form1.hkts.value="";
    return;
    }
    document.form1.hkrq.value=addDate(document.form1.tdrq.value,parseFloat(document.form1.hkts.value));
}
//引起回款日期变化--回款天数变化
function hkrqOnchange()
{
  var td = document.form1.tdrq.value;
  var datestr = td.replace(/-/gi, "/");
  var dt = new Date(datestr);
  var tds = dt.getTime();

  var hk = document.form1.hkrq.value;
  datestr = hk.replace(/-/gi, "/");
  dt = new Date(datestr);
  var hks = dt.getTime();

  document.form1.hkts.value=(hks-tds)/(1000*60*60*24);
}
function addDate(sdate,sl)
{
  var datestr = sdate.replace(/-/gi, "/");
  var dt = new Date(datestr);
  var dt2 = new Date(dt.getYear() + "/" + (dt.getMonth() + 1) + "/" + (dt.getDate()+sl));
  var obj = dt2.getYear() + "-" + (dt2.getMonth() + 1) + "-" + dt2.getDate();
  return obj;
}
function detailAdd()
{
  if(form1.dwtxid.value=='')
  {
  alert('请选择客户!');
  return;
  }
  if(form1.storeid.value=='')
  {
  alert('请选择仓库!');
  return;
}
sumitForm(<%=Operate.DETAIL_ADD%>);
}
function deptchange(){
   associateSelect(document.all['prod'], '<%=engine.project.SysConstant.BEAN_PERSON%>', 'personid', 'deptid', eval('form1.deptid.value'), '');
}
</script>
<%
  String retu = b_DirectSellBean.doService(request, response);
  if(retu.indexOf("backList();")>-1)
  {
    out.print(retu);
    return;
  }
  engine.project.LookUp balanceModeBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_BALANCE_MODE);//引用结算方式
  engine.project.LookUp corpBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_CORP);//引用往来单位
  engine.project.LookUp deptBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_DEPT);//引用部门
  engine.project.LookUp prodBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_PRODUCT);//引用产品
  engine.project.LookUp personBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_PERSON);//引用人员信息
  engine.project.LookUp storeBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_STORE);//引用仓库信息
  engine.project.LookUp saleOrderBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_SALE_ORDER_GOODS);//销售合同货物
  engine.project.LookUp propertyBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_SPEC_PROPERTY);//物资规格属性
  engine.project.LookUp salePriceBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_SALE_PRICE);
  engine.project.LookUp sendModeBean = engine.project.LookupBeanFacade.getInstance(request, engine.project.SysConstant.BEAN_SEND_MODE);//发货方式

  String curUrl = request.getRequestURL().toString();
  EngineDataSet ds = b_DirectSellBean.getMaterTable();
  EngineDataSet list = b_DirectSellBean.getDetailTable();
  HtmlTableProducer masterProducer = b_DirectSellBean.masterProducer;
  HtmlTableProducer detailProducer = b_DirectSellBean.detailProducer;
  RowMap masterRow = b_DirectSellBean.getMasterRowinfo();//主表一行
  RowMap[] detailRows= b_DirectSellBean.getDetailRowinfos();//从表多行
  corpBean.regData(ds, "dwtxid");
  if(b_DirectSellBean.isApprove)
  {
    personBean.regData(ds, "personid");
  }
  String djlx=masterRow.get("djlx");
  String zt=masterRow.get("zt");//0.初始化,1.已开提单(已经审核),4.作废,9.出库
  boolean isEnd =  b_DirectSellBean.isReport||b_DirectSellBean.isApprove || (!b_DirectSellBean.masterIsAdd() && !zt.equals("0"));
  boolean isCanDelete = !isEnd && !b_DirectSellBean.masterIsAdd() && loginBean.hasLimits(pageCode, op_delete);
  isEnd = isEnd || !(b_DirectSellBean.masterIsAdd() ? loginBean.hasLimits(pageCode, op_add) : loginBean.hasLimits(pageCode, op_edit));
  FieldInfo[] mBakFields = masterProducer.getBakFieldCodes();//主表用户的自定义字段
  String edClass = isEnd ? "class=edline" : "class=edbox";
  String detailClass = isEnd ? "class=edline" : "class=edFocused";
  String prodClass = detailClass;
  String detailClass_r = isEnd ? "class=ednone_r" : "class=edFocused_r";
  String readonly = isEnd ? " readonly" : "";
  String prodreanonly = readonly;
  String title = zt.equals("0") ? ("未审批") : ((zt.equals("9") ? "审批中" :(zt.equals("4")?"已作废":(zt.equals("8")?"完成":"已审"))) );
  String tdlx=djlx.equals("1")?"提货单":"退货单";
  boolean count=list.getRowCount()==0?true:false;
  RowMap corpRow =corpBean.getLookupRow(masterRow.get("dwtxid"));
  boolean canedt = zt.equals("0")||zt.equals("1")||zt.equals("2");
  String djandjjeClass = canedt ?"class=edFocused_r": "class=ednone_r" ;
  String dwtxClass = count? "class=edbox":"class=edline";
  String dwtxRead = count? " " : "readonly";
  boolean mustConversion = b_DirectSellBean.conversion;//是否需要强制转换
  String djhclass = zt.equals("2")?"class=edbox":"class=edline";
  String djhreadonly = zt.equals("2")?"":"readonly";
%>
<BODY id="docbody" oncontextmenu="window.event.returnValue=true"  onLoad="syncParentDiv('tableview1');">
<iframe id="prod" src="" width="95%" height=25 marginwidth=0 marginheight=0 hspace=0 vspace=0 frameborder=0 scrolling=no style="display:none"></iframe>
<form name="form1" action="<%=curUrl%>" method="POST" onsubmit="return false;" onKeyDown="return onInputKeyboard();" >
  <table WIDTH="100%" BORDER=0 CELLSPACING=0 CELLPADDING=0><tr>
    <td align="center" height="5"></td>
  </tr></table>
  <INPUT TYPE="HIDDEN" NAME="operate" value="">
  <INPUT TYPE="HIDDEN" NAME="rownum" value="">
  <INPUT TYPE="HIDDEN" NAME="djlx" value="<%=djlx%>">
  <table BORDER="0" CELLPADDING="1" CELLSPACING="0" align="center" width="760">
    <tr valign="top">
      <td><table border=0 CELLSPACING=0 CELLPADDING=0 class="table">
        <tr>
            <td class="activeVTab">销售发货单</td>
          </tr>
        </table>
  <table class="editformbox" CELLSPACING=1 CELLPADDING=0 >
          <tr>
            <td>
              <table CELLSPACING="1" CELLPADDING="1" BORDER="0" bgcolor="#f0f0f0" width="100%">
                 <tr>
                    <td  noWrap class="tdTitle">销售单号</td>
                    <td  noWrap class="td"><input type="text" name="tdbh" value='<%=masterRow.get("tdbh")%>' maxlength='<%=ds.getColumn("tdbh").getPrecision()%>' style="width:110" class="edline" onKeyDown="return getNextElement();" readonly></td>
                    <td   noWrap class="tdTitle"><%=masterProducer.getFieldInfo("storeid").getFieldname()%></td>
                    <td  noWrap class="td">
                    <%if(isEnd||!count){%>
                    <input type='hidden' name='storeid' value='<%=masterRow.get("storeid")%>'>
                    <input type='text' value='<%=storeBean.getLookupName(masterRow.get("storeid"))%>' style='width:110' class='edline' readonly>
                   <%
                    }else {%>
                    <pc:select name="storeid" addNull="1" style="width:110">
                      <%=storeBean.getList(masterRow.get("storeid"))%> </pc:select>
                   <%}%>
                  </td>
                    <td  noWrap class="tdTitle">发货日期</td>
                    <td  noWrap class="td">
                    <input type="text" name="tdrq" value='<%=masterRow.get("tdrq")%>' maxlength='10' style="width:110" <%=edClass%> onChange="tdrqOnchange()" <%=readonly%> >
                    <%if(!isEnd){%><a href="#"><img align="absmiddle" src="../images/seldate.gif" width="20" height="16" border="0" title="选择日期" onclick="selectTdrq()"></a><%}%>
                    </td>
                    <td noWrap class="tdTitle">直销店</td>
                    <td noWrap class="td">
                    <%
                      String onChange ="if(form1.deptid.value!='"+masterRow.get("deptid")+"')sumitForm("+Operate.DEPT_CHANGE+")";
                    %>
                    <%if(isEnd) out.print("<input type='hidden' name='deptid' value='"+masterRow.get("deptid")+"'><input type='text'  value='"+deptBean.getLookupName(masterRow.get("deptid"))+"' style='width:110' class='edline' readonly >");
                    else {%>
                    <pc:select name="deptid" addNull="1" style="width:110"  onSelect="deptchange();" >
                      <%=deptBean.getList(masterRow.get("deptid"))%> </pc:select>
                    <%}%>
                    </td>

               </tr>
               <tr>
                  <td  noWrap class="tdTitle">结算方式</td>
                  <td  noWrap class="td">
                    <%if(isEnd) out.print("<input type='hidden' name='jsfsid' value='"+masterRow.get("jsfsid")+"'><input type='text'   value='"+balanceModeBean.getLookupName(masterRow.get("jsfsid"))+"' style='width:110' class='edline' readonly >");
                    else {%>
                    <pc:select name="jsfsid"  addNull="1"  style="width:110">
                    <%=balanceModeBean.getList(masterRow.get("jsfsid"))%>
                    </pc:select>
                    <%}%></td>
                  <td  noWrap class="tdTitle">客户</td>
                  <td colspan="3" noWrap class="td">
                    <input type="hidden" name="dwtxid" value='<%=masterRow.get("dwtxid")%>'>
                    <input type="text" <%=dwtxClass%> style="width:70" onKeyDown="return getNextElement();" name="dwdm" value='<%=corpRow.get("dwdm")%>' onchange="customerCodeSelect(this)" <%=dwtxRead%>>
                    <input type="text" <%=dwtxClass%> name="dwmc" onKeyDown="return getNextElement();" value='<%=corpBean.getLookupName(masterRow.get("dwtxid"))%>' style="width:200"   onchange="customerNameSelect(this)"  <%=dwtxRead%>>
                    <%if(count){%>
                    <img style='cursor:hand' src='../images/view.gif' border=0 onClick="selectCustomer()">
                    <%}%>
                  </td>
                    <td noWrap class="tdTitle"><%=masterProducer.getFieldInfo("personid").getFieldname()%></td>
                    <td  noWrap class="td">
                    <%
                      if(!isEnd)
                        personBean.regConditionData(ds, "deptid");
                      if(isEnd) out.print("<input type='hidden' name='personid' value='"+masterRow.get("personid")+"'><input type='text'   value='"+personBean.getLookupName(masterRow.get("personid"))+"' style='width:110' class='edline' readonly>");
                      else {%>
                     <pc:select name="personid" style="width:110" >
                      <%=personBean.getList(masterRow.get("personid"), "deptid", masterRow.get("deptid"))%> </pc:select>
                    <%}%>
                   </td>
              </tr>
              <tr>
                <%/*打印用户自定义信息*/
                int j=0;
                while(j < mBakFields.length){
                  out.print("<tr>");
                  for(int k=0; k<4; k++)
                  {
                    out.print("<td noWrap class='tdTitle'>");
                    out.print(j < mBakFields.length ? mBakFields[j].getFieldname() : "&nbsp;");
                    out.print("</td><td noWrap class='td'");
                    if(j < mBakFields.length)
                    {
                      boolean isMemo = mBakFields[j].getType() == FieldInfo.MEMO_TYPE;
                      out.print(isMemo ? " colspan=7>" : ">");
                      String filedcode = mBakFields[j].getFieldcode();
                      String style = (isMemo ? "style='width:690'" : "style='width:110'")+ " onKeyDown='return getNextElement();'";
                      out.print(masterProducer.getFieldInput(mBakFields[j], masterRow.get(filedcode), filedcode, style, isEnd, true));
                      out.print("</td>");
                      if(isMemo)
                        break;
                    }
                    else
                      out.print(">&nbsp;</td>");
                    j++;
                  }
                  out.println("</tr>");
                }
                %>
                <tr>
                  <td colspan="8" noWrap class="td"><div style="display:block;width:750;overflow-y:auto;overflow-x:auto;">
                    <table id="tableview1" width="750" border="0" cellspacing="1" cellpadding="1" class="table" align="center">
                      <tr class="tableTitle">
                        <td nowrap width=10></td>
                        <td height='20' align="center" nowrap>
                          <%if(!isEnd){%><%if(b_DirectSellBean.canOperate){%>
                          <input name="image" class="img" type="image" title="新增(A)" onClick="detailAdd()" src="../images/add_big.gif" border="0">
                          <pc:shortcut key="a" script="detailAdd()" /><%}%>
                          <input class="edFocused_r"  name="tCopyNumber" value="1" title="拷贝(ALT+A)" size="2" maxlength="2" onChange=" if ( isNaN(this.value) ) this.value=1">
                          <%}%>
                        </td>
                        <td height='20' nowrap>产品代码</td>
                        <td height='20' nowrap>品名规格</td>
                        <td nowrap><%=detailProducer.getFieldInfo("sl").getFieldname()%></td>
                        <td height='20' nowrap>计量单位</td>
                        <td height='20' nowrap>零售价</td>
                        <td height='20' nowrap>折扣(%)</td>
                        <td nowrap><%=detailProducer.getFieldInfo("dj").getFieldname()%></td>
                        <td nowrap>金额</td>
                        <td nowrap><%=detailProducer.getFieldInfo("bz").getFieldname()%></td>
                        <%detailProducer.printTitle(pageContext, "height='20'", true);%>
                      </tr>
                    <%
                      propertyBean.regData(list,"dmsxid");
                      prodBean.regData(list,"cpid");
                      saleOrderBean.regData(list,"tdid");
                      salePriceBean.regData(list,"wzdjid");
                      BigDecimal t_sl = new BigDecimal(0), t_xsje = new BigDecimal(0), t_jje = new BigDecimal(0),t_hssl = new BigDecimal(0);
                      int i=0;
                      RowMap detail = null;
                      for(; i<detailRows.length; i++)   {
                        detail = detailRows[i];

                        RowMap productRow = prodBean.getLookupRow(detail.get("cpid"));
                        RowMap priceRow = salePriceBean.getLookupRow(detail.get("wzdjid"));

                        String isprops=productRow.get("isprops");
                        String cpid = detail.get("cpid");
                        String hsbl = productRow.get("hsbl");
                        detail.put("hsbl", hsbl);
                        RowMap  saleOrderRow= saleOrderBean.getLookupRow(detail.get("hthwid"));

                        boolean bh = detail.get("hthwid").equals("");
                        String instrstyle = bh?"class=edFocused_r": "class=ednone_r" ;

                        String dj = detail.get("dj");

                        String hssl = detail.get("hssl");
                        String sl = detail.get("sl");
                        String xsje = detail.get("xsje");
                        String jje = detail.get("jje");
                        String stsl = detail.get("stsl");
                        double dstsl = Double.parseDouble(stsl.equals("")?"0":stsl);
                        double dsl=0;
                        String wtsl = "";
                        if(b_DirectSellBean.isDouble(hssl))
                          t_hssl = t_hssl.add(new BigDecimal(hssl));

                        if(b_DirectSellBean.isDouble(sl))
                        {
                          dsl=Double.parseDouble(sl);
                          t_sl = t_sl.add(new BigDecimal(dsl));
                        }
                        if(b_DirectSellBean.isDouble(jje))
                          t_jje = t_jje.add(new BigDecimal(jje));
                        if(!detail.get("hthwid").equals(""))
                        {
                          prodClass="class=ednone";
                          prodreanonly="readonly";
                        }
                        else
                        {
                          prodClass = detailClass;
                          prodreanonly = readonly;
                        }
                        RowMap propertyRow = propertyBean.getLookupRow(detail.get("dmsxID"));
                        wtsl = engine.util.Format.formatNumber(dsl-dstsl,"#00.00");
                     %>
                      <tr id="rowinfo_<%=i%>">
                        <td class="td" nowrap><%=i+1%></td>
                        <td class="td" nowrap align="center">
                         <iframe id="prod_<%=i%>" src="" width="95%" height=25 marginwidth=0 marginheight=0 hspace=0 vspace=0 frameborder=0 scrolling=no style="display:none"></iframe>
                          <%if(!isEnd){%>
                          <%if(detail.get("hthwid").equals("")){%>
                          <img style='cursor:hand' src='../images/select_prod.gif' border=0 onClick="SaleProdSingleSelect('form1','srcVar=wzdjid_<%=i%>&srcVar=cpid_<%=i%>&storeid='+form1.storeid.value+'&dwtxid='+form1.dwtxid.value,'fieldVar=wzdjid&fieldVar=cpid','','sumitForm(<%=b_DirectSellBean.DETAIL_CHANGE%>,<%=i%>)')">
                          <%}%>
                          <input name="image" class="img" type="image" title="删除" onClick="if(confirm('是否删除该记录？')) sumitForm(<%=Operate.DETAIL_DEL%>,<%=i%>)" src="../images/delete.gif" border="0">
                          <input name="image" class="img" type="image" title="复制当前行" onClick="sumitForm(<%=b_DirectSellBean.DETAIL_COPY%>,<%=i%>)" src="../images/copyadd.gif" border="0">
                          <%}%></td>
                        <td class="td" nowrap>
                           <input type='hidden' id='hsbl_<%=i%>' name='hsbl_<%=i%>' value='<%=hsbl%>'>
                           <input type='hidden' id='truebl_<%=i%>' name='truebl_<%=i%>' value=''>
                           <input type='hidden' id='hthwid_<%=i%>' name='hthwid_<%=i%>' value='<%=detail.get("hthwid")%>'>
                           <input type='hidden' id='cpid_<%=i%>' name='cpid_<%=i%>' value='<%=detail.get("cpid")%>'>
                           <input type="hidden"  name="hssl_<%=i%>" value='<%=detail.get("hssl")%>'  readonly>
                           <input type="hidden"   name="hsdw_<%=i%>" value='<%=productRow.get("hsdw")%>'  readonly>
                           <input type="HIDDEN" id="wzdjid_<%=i%>" name="wzdjid_<%=i%>" value='<%=detail.get("wzdjid")%>' >
                           <input type="HIDDEN" id="xsje_<%=i%>" name="xsje_<%=i%>" value='<%=detail.get("xsje")%>' >
                           <input type="HIDDEN"  <%=djandjjeClass%>  name="sxz_<%=i%>" value='<%=propertyBean.getLookupName(detail.get("dmsxid"))%>' onchange="propertiesInput(this,form1.cpid_<%=i%>.value,<%=i%>)"  <%=canedt?"":" readonly"%> >
                           <input type="HIDDEN"  id="dmsxid_<%=i%>"  name="dmsxid_<%=i%>"  value='<%=detail.get("dmsxid")%>' <%=bh?"":"readonly"%> >

                           <input type="text" <%=prodClass%>  onKeyDown="return getNextElement();" name="cpbm_<%=i%>" value='<%=productRow.get("cpbm")%>' onchange="productCodeSelect(this,<%=i%>)" <%=prodreanonly%>>
                        </td>
                        <td class="td" nowrap>
                          <input type="text" <%=prodClass%>  onKeyDown="return getNextElement();" id="product_<%=i%>" name="product_<%=i%>" value='<%=productRow.get("product")%>'  onchange="productNameSelect(this,<%=i%>)"   <%=prodreanonly%>></td>
                        </td>
                        <%--td class="td" nowrap>
                        <input type="text"  <%=djandjjeClass%>  name="sxz_<%=i%>" value='<%=propertyBean.getLookupName(detail.get("dmsxid"))%>' onchange="propertiesInput(this,form1.cpid_<%=i%>.value,<%=i%>)"  <%=canedt?"":" readonly"%> >
                        <input type="HIDDEN"  id="dmsxid_<%=i%>"  name="dmsxid_<%=i%>"  value='<%=detail.get("dmsxid")%>' <%=bh?"":"readonly"%> >
                        <%if(canedt){%>
                        <img style='cursor:hand' src='../images/view.gif' border=0 onClick="if('<%=detail.get("cpid")%>'==''){alert('请先输入产品');return;}if('<%=isprops%>'=='0'){alert('该产品无规格属性!');return;}PropertySelect('form1','dmsxid_<%=i%>','sxz_<%=i%>','<%=cpid%>')"><%}%>
                        <%if(!isEnd&&!isprops.equals("0")){%><img style='cursor:hand' src='../images/delete.gif' BORDER=0 ONCLICK="dmsxid_<%=i%>.value='';sxz_<%=i%>.value='';"><%}%>
                        </td--%>
                        <td class="td" nowrap><input type="text" <%=djandjjeClass%>  onKeyDown="return getNextElement();" id="sl_<%=i%>" name="sl_<%=i%>" value='<%=detail.get("sl")%>' maxlength='<%=list.getColumn("sl").getPrecision()%>' onblur="sl_onchange(<%=i%>, false)" <%=canedt?"":" readonly"%>></td><!--数量-->
                        <td class="td" nowrap><%=productRow.get("jldw")%></td><!--计量单位--->
                        <td class="td" nowrap><input type="text" class='ednone_r'   onKeyDown="return getNextElement();" id="xsj_<%=i%>" name="xsj_<%=i%>" value='<%=detail.get("xsj")%>' readonly></td><!--销售价-->
                        <td class="td" nowrap><input type="text" <%=detailClass_r%>   onKeyDown="return getNextElement();" id="zk_<%=i%>" name="zk_<%=i%>" value='<%=detail.get("zk")%>'  onchange="dj_onchange(<%=i%>, true)" <%=readonly%>></td><!--折扣-->
                        <td class="td" nowrap><input type="text" <%=detailClass_r%>   onKeyDown="return getNextElement();" id="dj_<%=i%>" name="dj_<%=i%>" value='<%=detail.get("dj")%>' onchange="dj_onchange(<%=i%>, false)"  <%=readonly%> ></td><!--单价-->
                        <td class="td" nowrap><input type="text" class='ednone_r'  onKeyDown="return getNextElement();" id="jje_<%=i%>" name="jje_<%=i%>" value='<%=detail.get("jje")%>'  readonly></td><!--净金额-->
                        <td class="td" nowrap align="left"><input type="text" <%=detailClass%>  onKeyDown="return getNextElement();" name="bz_<%=i%>" id="bz_<%=i%>" value='<%=detail.get("bz")%>' maxlength='100'  <%=readonly%> ></td><!--备注-->
                      </tr>
                      <%list.next();
                      }
                      for(; i < 4; i++){
                  %>
                      <tr id="rowinfo_<%=i%>">
                        <td class="td">&nbsp;</td><td class="td">&nbsp;</td><td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td><td class="td">&nbsp;</td><td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td><td class="td">&nbsp;</td><td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td><td class="td">&nbsp;</td>
                        <%detailProducer.printBlankCells(pageContext, "class=td", true);%>
                      </tr>
                      <%}%>
                      <tr id="rowinfo_end">
                        <td class="td">&nbsp;</td>
                        <td class="td" nowrap> 合计 </td>
                        <td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td>
                        <td class="td" nowrap><input id="t_sl" name="t_sl" type="text" class='ednone_r' style="width:100%" value='<%=engine.util.Format.formatNumber(t_sl.toString(),loginBean.getSumFormat())%>' readonly></td>
                        <td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td>
                        <td class="td">&nbsp;</td>
                        <td class="td" nowrap><input id="t_jje" name="t_jje" type="text" class='ednone_r' style="width:100%" value='<%=engine.util.Format.formatNumber(t_jje.toString(),loginBean.getPriceFormat())%>'  readonly></td>
                        <td class="td">&nbsp;</td>
                        <%detailProducer.printBlankCells(pageContext, "class=td", true);%>
                      </tr>
                    </table></div>
                    <SCRIPT LANGUAGE="javascript">rowinfo = new RowControl();
                      <%for(int k=0; k<i; k++)
                        {
                         out.print("AddRowItem(rowinfo,'rowinfo_"+k+"');");
                       }%>
                      AddRowItem(rowinfo,'rowinfo_end');
                      InitRowControl(rowinfo);
                      initDefaultTableRow('tableview1',1);
                      <%=b_DirectSellBean.adjustInputSize(new String[]{"cpbm","product","sl","zk","dj","bz"}, "form1", detailRows.length)%>
                    </SCRIPT>
                    <%--=b_DirectSellBean.adjustInputSize(new String[]{"cpbm","pm","gg","sxz","sl","dj","bz"}, "form1", detailRows.length)--%>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </td>
</tr>
    <tr>
      <td>
        <table CELLSPACING=0 CELLPADDING=0 width="100%" align="center">
          <tr>
            <td class="td"><b>登记日期:</b><%=masterRow.get("czrq")%></td>
            <td class="td"></td>
            <td class="td" align="right"><b>制单人:</b><%=masterRow.get("czy")%></td>
          </tr>
          <tr>
            <td colspan="3" noWrap class="tableTitle">
             <%
               if(!isEnd){
               String retun = "sumitForm("+Operate.POST_CONTINUE+")";
              %>
              <input name="button2"  style="width:80" type="button" class="button" onClick="sumitForm(<%=Operate.POST_CONTINUE%>);" value="保存新增(N)">
              <pc:shortcut key="n" script="<%=retun%>" />
              <%
               }
               if(zt.equals("0"))
               {
                 if(!b_DirectSellBean.isReport){
                   String post ="sumitForm("+Operate.POST+");";
               %>
              <input name="btnback" style="width:80" type="button" class="button" onClick="sumitForm(<%=Operate.POST%>);" value="保存返回(S)">
              <pc:shortcut key="s" script="<%=post%>" />
               <%}
               }if(zt.equals("1")||zt.equals("2")){
                 if(!b_DirectSellBean.isReport){
                   String appost ="sumitForm("+b_DirectSellBean.APPROVED_MASTER_ADD+");";
             %>
              <input name="btnback" style="width:80" type="button" class="button" onClick="sumitForm(<%=b_DirectSellBean.APPROVED_MASTER_ADD%>);" value="保存(S)">
              <pc:shortcut key="s" script="<%=appost%>" />
              <%
              }}if(isCanDelete&&!b_DirectSellBean.isReport){
               String del = "if(confirm('是否删除该记录？'))sumitForm("+Operate.DEL+");";
               String detNull = "sumitForm("+b_DirectSellBean.DEL_NULL+");";
              %>
              <input name="button3"  style="width:110" type="button" class="button" title="删除空行(R)" value="删除数量为空行(R)" onClick="<%=detNull%>">
              <pc:shortcut key="r" script="<%=detNull%>" />
              <input name="button3"  style="width:60" type="button" class="button" onClick="if(confirm('是否删除该记录？'))sumitForm(<%=Operate.DEL%>);" value="删除(D)">
              <pc:shortcut key="d" script="<%=del%>" />
              <%
              }if(!b_DirectSellBean.isReport){
              %>
              <input name="btnback"  style="width:50" type="button" class="button" onClick="backList();" value="返回(C)">
              <pc:shortcut key="c" script="backList();" /><%}%>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</form>
<script language="javascript">

  function formatQty(srcStr){ return formatNumber(srcStr, '<%=loginBean.getQtyFormat()%>');}
  function formatPrice(srcStr){ return formatNumber(srcStr, '<%=loginBean.getPriceFormat()%>');}
  function formatSum(srcStr){ return formatNumber(srcStr, '<%=loginBean.getSumFormat()%>');}
    function sl_onchange(i, isBigUnit)
    {
      var oldhsblObj = document.all['hsbl_'+i];
      var sxzObj = document.all['sxz_'+i];
      unitConvert(document.all['prod_'+i], 'form1', 'srcVar=truebl_'+i, 'exp='+oldhsblObj.value, sxzObj.value, 'nsl_onchange('+i+','+isBigUnit+')');
     }
  function nsl_onchange(i, isBigUnit)
  {
    var slObj = document.all['sl_'+i];
    var xsjObj = document.all['xsj_'+i];
    var djObj = document.all['dj_'+i];
    var jjeObj = document.all['jje_'+i];
    var hsblObj = document.all['truebl_'+i];
    var hsslObj = document.all['hssl_'+i];
    var obj = isBigUnit ? hsslObj : slObj;
    var showText = isBigUnit ? "输入的换算数量非法！" : "输入的数量非法！";//显示错误信息
    var changeObj = isBigUnit ? slObj : hsslObj;//所调用的控件
    if(obj.value=="")
      return;
    if(obj.value.trim()=="")
      return;
    if(isNaN(obj.value)){
      alert(showText);
      obj.focus();
      return;
    }
    if(!hsblObj.value=="")
  {
    <%
    if(mustConversion){
    //要强制转换
    %>
    changeObj.value = formatPrice(isBigUnit ? (parseFloat(hsslObj.value)*parseFloat(hsblObj.value)) : (parseFloat(slObj.value)/parseFloat(hsblObj.value)));
    <%}else {%>
      if(hsslObj.value==""||slObj.value=="")
        changeObj.value = formatPrice(isBigUnit ? (parseFloat(hsslObj.value)*parseFloat(hsblObj.value)) : (parseFloat(slObj.value)/parseFloat(hsblObj.value)));
      <%}%>
  }
    if(djObj.value!="" && !isNaN(djObj.value))
      jjeObj.value = formatPrice(parseFloat(slObj.value) * parseFloat(djObj.value));
    cal_tot('sl');
    cal_tot('jje');
  }
  function dj_onchange(i, isRebate)
  {
    var slObj = document.all['sl_'+i];
    var zkObj = document.all['zk_'+i];
    var xsjObj = document.all['xsj_'+i];
    var djObj = document.all['dj_'+i];
    var jjeObj = document.all['jje_'+i];

    var obj = isRebate ? zkObj : djObj;
    var showText = isRebate ? "输入的折扣非法！" : "输入的单价非法！";
    var changeObj = isRebate ? djObj : zkObj;
    if(obj.value=="")
      return;
    if(isNaN(obj.value)){
      alert(showText);
      obj.focus();
      return ;
    }
    if(parseFloat(xsjObj.value)==0)
      changeObj.value = formatQty(isRebate ? (parseFloat(xsjObj.value)*parseFloat(zkObj.value)/100) : 0);
    else
      changeObj.value = formatQty(isRebate ? (parseFloat(xsjObj.value)*parseFloat(zkObj.value)/100) : (parseFloat(djObj.value)/parseFloat(xsjObj.value)*100));    if(slObj.value!="" && !isNaN(slObj.value))
    if(slObj.value!="" && !isNaN(slObj.value))
      jjeObj.value = formatPrice(parseFloat(slObj.value) * parseFloat(djObj.value));
    cal_tot('jje');
  }
  function cal_tot(type)
  {
    var tmpObj;
    var tot=0;
    for(i=0; i<<%=detailRows.length%>; i++)
    {
      if(type == 'sl')
        tmpObj = document.all['sl_'+i];
      else if(type == 'jje')
        tmpObj = document.all['jje_'+i];
      else
        return;
      if(tmpObj.value!="" && !isNaN(tmpObj.value))
        tot += parseFloat(tmpObj.value);
    }
    if(type == 'sl')
      document.all['t_sl'].value = formatQty(tot);
    else if(type == 'jje')
      document.all['t_jje'].value = formatPrice(tot);
  }


 function prodsMultiSelect(frmName, srcVar)
  {
    var winopt = "location=no scrollbars=yes menubar=no status=no resizable=1 width=500 height=400 top=0 left=0";
    var winName= "GoodsProdSelector";
    paraStr = "../sale_xixing/import_apply_select.jsp?operate=0&srcFrm="+frmName+"&"+srcVar;
    newWin =window.open(paraStr,winName,winopt);
    newWin.focus();
  }
 function goodsMultiSelect(frmName, srcVar, storeid)
  {
    var winopt = "location=no scrollbars=yes menubar=no status=no resizable=1 width=790 height=570 top=0 left=0";
    var winName= "GoodsProdSelector";
    paraStr = "../sale/lading_sel_product.jsp?operate=0&srcFrm="+frmName+"&"+srcVar+"&curID="+storeid;
    newWin =window.open(paraStr,winName,winopt);
    newWin.focus();
  }
function OrderSingleSelect(frmName,srcVar,fieldVar,curID,methodName,notin)
  {
   var winopt = "location=no scrollbars=yes menubar=no status=no resizable=1 width=800 height=600  top=0 left=0";
   var winName= "SingleOrderSelector";
   paraStr = "../sale/import_order.jsp?operate=0&srcFrm="+frmName+"&"+srcVar+"&"+fieldVar+curID;
   if(methodName+'' != 'undefined')
     paraStr += "&method="+methodName;
   if(notin+'' != 'undefined')
     paraStr += "&notin="+notin;
   newWin =window.open(paraStr,winName,winopt);
   newWin.focus();
  }
function propertiesInput(obj,cpid,i)
  {
    PropertyNameChange(document.all['prod'], obj.form.name, 'srcVar=dmsxid_'+i+'&srcVar=sxz_'+i, 'fieldVar=dmsxid&fieldVar=sxz', cpid, obj.value, 'sumitForm(<%=b_DirectSellBean.DETAIL_CHANGE%>,'+i+')');
  }
function selctorder()
  {
  if(form1.dwtxid.value=='')
  {
    alert('请选择购货单位');
    return;
  }
  if(form1.storeid.value=='')
  {
    alert('请选择仓库');
    return;
  }
  form1.selectedhtid.value='';
    OrderSingleSelect('form1','srcVar=selectedhtid','fieldVar=htid','&dwtxid='+form1.dwtxid.value+'&djlx='+form1.djlx.value+'&storeid='+form1.storeid.value,"sumitForm(<%=b_DirectSellBean.IMPORT_ORDER%>,-1)");
  }
function checkdwst()
  {
  if(form1.storeid.value=='')
  {
    alert('请选择仓库');
    return;
  }
  OrderMultiSelect('form1','srcVar=importOrder&dwtxid='+form1.dwtxid.value+'&khlx='+form1.khlx.value+'&storeid='+form1.storeid.value+'&djlx='+form1.djlx.value+'&personid='+form1.personid.value+'&jsfsid='+form1.jsfsid.value+'&sendmodeid='+form1.sendmodeid.value)
}
function OrderMultiSelect(frmName, srcVar, methodName,notin)
{
     var winopt = "location=no scrollbars=yes menubar=no status=no resizable=1 width=700 height=600 top=0 left=0";
     var winName= "OrdersSelector";
     paraStr = "../sale_xixing/import_order.jsp?operate=0&srcFrm="+frmName+"&"+srcVar;
     if(methodName+'' != 'undefined')
       paraStr += "&method="+methodName;
     if(notin+'' != 'undefined')
     paraStr += "&notin="+notin;
     openSelectUrl(paraStr, winName, winopt2);
}
function checkdwtxid()
{
  if(form1.dwtxid.value=='')
  {
    alert('请选择购货单位');
    return;
  }
  if(form1.storeid.value=='')
  {
    alert('请选择仓库');
    return;
  }
  if(form1.personid.value=='')
  {
    alert('请选择业务员');
    return;
  }
  if(form1.jsfsid.value=='')
  {
    alert('请选择结算方式');
    return;
  }
  MultiSelectOrder('form1','srcVar=importOrderproduct&dwtxid='+form1.dwtxid.value+'&storeid='+form1.storeid.value+'&djlx=1&personid='+form1.personid.value+'&jsfsid='+form1.jsfsid.value)
}
function MultiSelectOrder(frmName, srcVar, methodName,notin)
{
  var winopt = "location=no scrollbars=yes menubar=no status=no resizable=1 width=700 height=600 top=0 left=0";
  var winName= "OrdersSelector";
  paraStr = "../sale_xixing/select_order_product.jsp?operate=0&srcFrm="+frmName+"&"+srcVar;
  if(methodName+'' != 'undefined')
    paraStr += "&method="+methodName;
  if(notin+'' != 'undefined')
    paraStr += "&notin="+notin;
  newWin =window.open(paraStr,winName,winopt);
  newWin.focus();
}
//产品编码
function productCodeSelect(obj, i)
{
    SaleProdCodeChange(document.all['prod'], obj.form.name,'srcVar=wzdjid_'+i+'&srcVar=cpid_'+i+'&dwtxid='+form1.dwtxid.value,'fieldVar=wzdjid&fieldVar=cpid&storeid='+form1.storeid.value,obj.value,'sumitForm(<%=b_DirectSellBean.DETAIL_CHANGE%>,'+i+')');
}
//产品名称
function productNameSelect(obj, i)
{
    SaleProdNameChange(document.all['prod'], obj.form.name,'srcVar=wzdjid_'+i+'&srcVar=cpid_'+i+'&dwtxid='+form1.dwtxid.value,'fieldVar=wzdjid&fieldVar=cpid&storeid='+form1.storeid.value,obj.value,'sumitForm(<%=b_DirectSellBean.DETAIL_CHANGE%>,'+i+')');
}
</script>
<%//&#$
if(b_DirectSellBean.isApprove){%><jsp:include page="../pub/approve.jsp" flush="true"/><%}%>
<%out.print(retu);%>
</BODY>
</Html>