<%@ page contentType="text/html; charset=UTF-8" %><%@
include file="../pub/init.jsp"%>
<%@
page import="engine.dataset.*,engine.project.Operate,engine.report.util.ReportData,java.math.BigDecimal,engine.html.*,java.util.ArrayList"
%>
<%
  engine.erp.store.xixing.B_AssistantMaterialCollect B_AssistantMaterialCollectBean = engine.erp.store.xixing.B_AssistantMaterialCollect.getInstance(request);//得到实例(初始化实例变量)
  RowMap[] drows = B_AssistantMaterialCollectBean.getXsRowinfos();
  RowMap masterRow = B_AssistantMaterialCollectBean.masterRow;
  ReportData td = new ReportData();
  td.addReportData("ds", masterRow);
  td.addReportData("list", drows);
  request.setAttribute("dzd",td);
  pageContext.forward("../pub/pdfprint.jsp?operate="+Operate.PRINT_PRECISION+"&code=assist_collect_print");
%>