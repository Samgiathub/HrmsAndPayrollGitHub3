using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095EmpImeiDetail
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string ImeiNo { get; set; } = null!;

    public byte IsActive { get; set; }

    public DateTime? RegisteredDate { get; set; }

    public decimal? RegisteredBy { get; set; }

    public DateTime? InActiveDate { get; set; }

    public decimal? InActiveBy { get; set; }

    public DateTime? SysDatetime { get; set; }

    public string? DeviceId { get; set; }
}
