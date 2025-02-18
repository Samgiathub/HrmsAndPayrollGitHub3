using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040RoleMaster
{
    public decimal RoleId { get; set; }

    public decimal? CmpId { get; set; }

    public string? RoleName { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public string? IpAddress { get; set; }
}
