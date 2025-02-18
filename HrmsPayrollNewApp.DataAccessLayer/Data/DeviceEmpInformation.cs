using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class DeviceEmpInformation
{
    public decimal IpAddressId { get; set; }

    public string IpAddress { get; set; } = null!;

    public decimal CardId { get; set; }

    public decimal FingerId { get; set; }

    public string FingerTemplate { get; set; } = null!;

    public decimal? Pwd { get; set; }

    public decimal? Priviledge { get; set; }

    public string? Name { get; set; }

    public int? IsFinger { get; set; }
}
