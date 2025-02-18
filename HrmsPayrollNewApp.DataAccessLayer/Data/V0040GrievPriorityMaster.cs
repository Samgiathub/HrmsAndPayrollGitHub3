using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040GrievPriorityMaster
{
    public int GPriorityId { get; set; }

    public string PriorityTitle { get; set; } = null!;

    public string PriorityCode { get; set; } = null!;

    public int? CmpId { get; set; }
}
