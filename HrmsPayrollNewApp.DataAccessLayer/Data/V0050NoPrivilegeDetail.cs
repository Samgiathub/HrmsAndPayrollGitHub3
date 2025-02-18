using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050NoPrivilegeDetail
{
    public decimal PrivilageId { get; set; }

    public decimal FormId { get; set; }

    public string FormName { get; set; } = null!;

    public string? Alias { get; set; }

    public string? FormUrl { get; set; }
}
