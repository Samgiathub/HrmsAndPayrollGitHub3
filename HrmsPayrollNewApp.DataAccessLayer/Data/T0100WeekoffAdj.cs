using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100WeekoffAdj
{
    public decimal WTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public string WeekoffDay { get; set; } = null!;

    public string? WeekoffDayValue { get; set; }

    public string? AltWName { get; set; }

    public string? AltWFullDayCont { get; set; }

    public string? AltWHalfDayCont { get; set; }

    public byte? IsPComp { get; set; }

    public bool? IsMakerChecker { get; set; }

    public string? WeekOffOddEven { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
