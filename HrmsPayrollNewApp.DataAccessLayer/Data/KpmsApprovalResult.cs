using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsApprovalResult
{
    public int ApprResultId { get; set; }

    public int? ApprrResult { get; set; }

    public int? EmpId { get; set; }

    public int? RmId { get; set; }

    public int? CmpId { get; set; }
}
