using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120GatePassApproval
{
    public decimal AprId { get; set; }

    public decimal AppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime AprDate { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime FromTime { get; set; }

    public DateTime ToTime { get; set; }

    public string Duration { get; set; } = null!;

    public decimal ReasonId { get; set; }

    public string? ManagerRemarks { get; set; }

    public DateTime? AprSystemDatetime { get; set; }

    public string AprStatus { get; set; } = null!;

    public decimal? AprUserId { get; set; }

    public decimal? SecurityOutTimeUserId { get; set; }

    public decimal? SecurityInTimeUserId { get; set; }

    public DateTime? ActualOutTime { get; set; }

    public DateTime? ActualInTime { get; set; }

    public string? ActualDuration { get; set; }

    public virtual T0100GatePassApplication App { get; set; } = null!;
}
