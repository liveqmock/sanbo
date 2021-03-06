package engine.erp.report.store;

import java.util.Hashtable;
import javax.servlet.ServletRequest;
import engine.report.util.TempletData;
import engine.report.util.ContextData;
import engine.dataset.EngineDataSet;
import engine.report.event.ReportDataLoadingListener;
import engine.dataset.sql.QueryWhere;
import engine.util.MessageFormat;

/**
 * <p>Title: 库存库存量表</p>
 * <p>Description: 库存收发单据汇总表</p>
 * <p>Copyright: Copyright (c) 2003</p>
 * <p>Company: </p>
 * @author 李建华
 * @version 1.0
 */

public class B_StockNumber implements ReportDataLoadingListener
{
  private Hashtable fieldTable = new Hashtable();

  //提取包含未记帐的存货收发明细
  private final static String STOCK_NUMBER_SQL
    = "SELECT * FROM ("
      + "SELECT cpid, cpbm, pm, gg, jldw,hsdw, sum(nvl(kcsl,0)) kcsl,sum(nvl(kchssl,0)) kchssl, sum(nvl(wjzssl,0)) wjzssl,"
      + "       sum(nvl(wjzfsl,0)) wjzfsl, sum(nvl(kcsl,0))+sum(nvl(hjsl,0)) hjsl,"
      + "       sum(nvl(kchssl,0))+sum(nvl(hjhssl,0)) hjhssl "
      + "FROM"
      + "("
      //  --得到期初结存期初未记帐的单据也计算
      + "  SELECT  c.cpid, c.cpbm, c.pm, c.gg, c.jldw,c.hsdw, (SUM(nvl(srsl,0))-SUM(nvl(fcsl,0))) kcsl,"
      + "          (SUM(nvl(srhssl,0))-SUM(nvl(fchssl,0))) kchssl,"
      + "          NULL wjzssl, NULL wjzfsl, NULL hjsl, NULL hjhssl"
//      + "  FROM"
//      + "  ("
//      + "    SELECT c.cpid, c.cpbm, c.pm, c.gg, c.jldw,c.hsdw, SUM(nvl(a.srsl,0)) srsl,"
//      + "          SUM(nvl(a.fcsl,0)) fcsl, SUM(nvl(a.srhssl,0)) srhssl, SUM(nvl(a.fchssl,0)) fchssl"
      + "    FROM vw_kc_storebill a, kc_dm c"
      + "    WHERE a.cpid=c.cpid"
      + "    AND a.sfrq < to_date('{startdate}', 'YYYY-MM-DD') AND a.fgsid={fgsid}"
      + "    {cpid} {storeid} {chlbid} {startcpbm} {endcpbm} {pm} {gg}"
      + "    GROUP BY c.cpid,c.cpbm, c.pm, c.gg, c.jldw,c.hsdw"
//      + "  ) e"
//      + "  GROUP BY cpid, cpbm, pm, gg, jldw,hsdw"
      + "  UNION ALL"
      //  --得到查询段时间记帐数量
      + "  SELECT  c.cpid, c.cpbm, c.pm, c.gg, c.jldw,c.hsdw, (SUM(nvl(srsl,0))-SUM(nvl(fcsl,0))) kcsl,"
      + "          (SUM(nvl(srhssl,0))-SUM(nvl(fchssl,0))) kchssl,"
      + "          NULL wjzssl, NULL wjzfsl, NULL hjsl, NULL hjhssl"
//      + "  FROM"
//      + "  ("
//      + "    SELECT c.cpid, c.cpbm, c.pm, c.gg, c.jldw,c.hsdw, SUM(nvl(a.srsl,0)) srsl,"
//      + "          SUM(nvl(a.fcsl,0)) fcsl, SUM(nvl(a.srhssl,0)) srhssl, SUM(nvl(a.fchssl,0)) fchssl"
      + "    FROM vw_kc_storebill a, kc_dm c"
        //--得到查询段时间记帐数量
      + "    WHERE a.cpid=c.cpid AND (a.zt=2 OR a.zt=8)"
      + "    AND  a.sfrq>=to_date('{startdate}', 'YYYY-MM-DD') AND a.sfrq<=to_date('{enddate}', 'YYYY-MM-DD') AND a.fgsid={fgsid}"
      + "    {cpid} {storeid} {chlbid} {startcpbm} {endcpbm} {pm} {gg}"
      + "    GROUP BY c.cpid,c.cpbm, c.pm, c.gg, c.jldw,c.hsdw"
//      + "  ) e"
//      + "  GROUP BY cpid, cpbm, pm, gg, jldw,hsdw"
      + "  UNION ALL"
      + "  SELECT  c.cpid, c.cpbm, c.pm, c.gg, c.jldw,c.hsdw, NULL kcsl, NULL kchssl, SUM(nvl(a.srsl,0)) wjzssl, SUM(nvl(a.fcsl,0)) wjzfsl, SUM(nvl(a.srsl,0))-SUM(nvl(a.fcsl,0)) hjsl,"
      + "         SUM(nvl(a.srhssl,0))-SUM(nvl(a.fchssl,0)) hjhssl"
//      + "  FROM "
        //--得到该时间段输入输出数据
//      + "  ("
//      + "    SELECT c.cpid, c.cpbm, c.pm, c.gg, c.jldw,c.hsdw, SUM(nvl(a.srsl,0)) wjzssl,"
//      + "          SUM(nvl(a.fcsl,0)) wjzfsl, SUM(nvl(a.srhssl,0)) wjzsrhssl,"
//      + "          SUM(nvl(a.fchssl,0)) wjzfchssl"
      + "    FROM vw_kc_storebill a, kc_dm c"
      + "    WHERE a.cpid=c.cpid AND a.zt<>2 AND a.zt<>8"
      + "    AND  a.sfrq>=to_date('{startdate}', 'YYYY-MM-DD') AND a.sfrq<=to_date('{enddate}', 'YYYY-MM-DD') AND a.fgsid={fgsid}"
      + "    {cpid} {storeid} {chlbid} {startcpbm} {endcpbm} {pm} {gg}"
      + "    GROUP BY c.cpid, c.cpbm, c.pm, c.gg, c.jldw,c.hsdw"
 //     + "  ) f"
      + ") g GROUP BY cpid, cpbm, pm, gg, jldw,hsdw ORDER BY cpbm"
    +") T {advance} ";

  /**
   * 报表数据打开时的事件调用的方法。1:组装SQL语句，提取数据
   * @param request WEB请求
   * @param templet 报表模板对象
   * @param context 报表上下文对象
   * @param dsRep   报表数据对象对象
   * @param whereQuery 查询条件的所有值
   */
  public void dataLoading(ServletRequest request, TempletData templet, ContextData context,
                          EngineDataSet dsRep, QueryWhere whereQuery)
  {
    String startdate = whereQuery.getWhereValue("a$ksrq");
    String enddate = whereQuery.getWhereValue("a$jsrq");
    String fgsid = whereQuery.getWhereValue("a$fgsid");
    String cpid = whereQuery.getWhereValue("a$cpid");
    String storeid = whereQuery.getWhereValue("a$storeid");
    String chlbid = whereQuery.getWhereValue("a$chlbid");
    String startcpbm = whereQuery.getWhereValue("a$startcpbm");
    String endcpbm = whereQuery.getWhereValue("a$endcpbm");
    String pm = whereQuery.getWhereValue("a$pm");
    String gg = whereQuery.getWhereValue("a$gg");
    if(cpid.length() > 0)
      cpid = "AND a.cpid="+cpid;
    if(storeid.length() > 0)
      storeid = "AND a.storeid="+storeid;
    if(chlbid.length() > 0)
      chlbid = "AND c.chlbid="+chlbid;
    if(startcpbm.length() > 0)
      startcpbm = "AND c.cpbm >= '"+ startcpbm +"'";
    if(endcpbm.length() > 0)
      endcpbm = "AND c.cpbm <= '"+ endcpbm +"'";
    if(pm.length() > 0)
      pm = "AND c.pm LIKE '%"+ pm +"%'";
    if(gg.length() > 0)
      gg = "AND c.gg LIKE '%"+ gg +"%'";

    fieldTable.clear();
    fieldTable.put("startdate", startdate);
    fieldTable.put("enddate", enddate);
    fieldTable.put("fgsid", fgsid);
    fieldTable.put("storeid", storeid);
    fieldTable.put("cpid", cpid);
    fieldTable.put("storeid", storeid);
    fieldTable.put("chlbid", chlbid);
    fieldTable.put("startcpbm", startcpbm);
    fieldTable.put("endcpbm", endcpbm);
    fieldTable.put("pm", pm);
    fieldTable.put("gg", gg);
    String advance = context.getAdvanceWhere().getWhereQuery();
    fieldTable.put("advance", advance.length()>0 ? " WHERE "+advance : "");

    String sql = MessageFormat.format(STOCK_NUMBER_SQL, fieldTable);
    dsRep.setQueryString(sql);
    if(dsRep.isOpen())
      dsRep.refresh();
    else
      dsRep.openDataSet();
  }
}


