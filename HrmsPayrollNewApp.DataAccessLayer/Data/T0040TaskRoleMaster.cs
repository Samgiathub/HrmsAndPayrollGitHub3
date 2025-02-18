using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TaskRoleMaster
{
    public int RoleId { get; set; }

    public string? RCode { get; set; }

    public string? RTitle { get; set; }

    public int? RStatus { get; set; }

    public DateTime? RCreatedDate { get; set; }

    public DateTime? RUpdatedDate { get; set; }
}
