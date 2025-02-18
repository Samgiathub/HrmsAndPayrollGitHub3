using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115GatePassLevelApproval
{
    public decimal TranId { get; set; }

    public decimal AppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime AprDate { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime FromTime { get; set; }

    public DateTime ToTime { get; set; }

    public string Duration { get; set; } = null!;

    public decimal ReasonId { get; set; }

    public string? AprRemarks { get; set; }

    public decimal? AprUserId { get; set; }

    public DateTime? SystemDatetime { get; set; }

    public string? AprStatus { get; set; }

    public decimal SEmpId { get; set; }

    public decimal RptLevel { get; set; }

    public virtual T0100GatePassApplication App { get; set; } = null!;
}
