using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115AttendanceReguLevelApproval
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal IoTranId { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? OutTime { get; set; }

    public string? Duration { get; set; }

    public string? Reason { get; set; }

    public decimal? SkipCount { get; set; }

    public decimal? LateCalcNotApp { get; set; }

    public byte? ChkBySuperior { get; set; }

    public string? HalfFullDay { get; set; }

    public byte? IsCancelLateIn { get; set; }

    public byte? IsCancelEarlyOut { get; set; }

    public decimal? SEmpId { get; set; }

    public string? SComment { get; set; }

    public byte RptLevel { get; set; }

    public DateTime SystemDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
