using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0070WeekoffAdjApp
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int WTranId { get; set; }

    public int CmpId { get; set; }

    public string WeekoffDay { get; set; } = null!;

    public string? WeekoffDayValue { get; set; }

    public string? AltWName { get; set; }

    public string? AltWFullDayCont { get; set; }

    public string? AltWHalfDayCont { get; set; }

    public byte? IsPComp { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
