using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsApproveStatus
{
    public int ApprStatusId { get; set; }

    public int? CmpId { get; set; }

    public string? StatusName { get; set; }
}
