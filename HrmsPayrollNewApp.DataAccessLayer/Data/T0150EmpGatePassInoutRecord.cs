using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150EmpGatePassInoutRecord
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime? OutTime { get; set; }

    public DateTime? InTime { get; set; }

    public string Hours { get; set; } = null!;

    public decimal ReasonId { get; set; }

    public byte Exempted { get; set; }

    public string IpAddress { get; set; } = null!;

    public byte IsApproved { get; set; }

    public byte IsDefault { get; set; }

    public string? ShiftStTime { get; set; }

    public string? ShiftEndTime { get; set; }

    public decimal? AppId { get; set; }
}
