using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040IpMaster
{
    public decimal IpId { get; set; }

    public string IpAddress { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal DeviceNo { get; set; }

    public string DeviceModel { get; set; } = null!;

    public decimal IsActive { get; set; }

    public decimal BaudRate { get; set; }

    public decimal CommKey { get; set; }

    public decimal CommPort { get; set; }

    public string? DeviceType { get; set; }

    public string? DeviceName { get; set; }

    public byte IsGatePass { get; set; }

    public byte IsTraining { get; set; }

    public byte IsCanteen { get; set; }

    public string? Flag { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
