using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040GrievCategoryMaster
{
    public int GCategoryId { get; set; }

    public string CategoryTitle { get; set; } = null!;

    public string CategoryCode { get; set; } = null!;

    public int? CmpId { get; set; }
}
