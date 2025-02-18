using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ClaimGroupMaster
{
    public int ClaimGroupId { get; set; }

    public int? CmpId { get; set; }

    public string? ClaimGroupName { get; set; }

    public DateTime? SystemDate { get; set; }
}
