using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040GrievCategoryMaster
{
    public int GCategoryId { get; set; }

    public string? CategoryCode { get; set; }

    public string CategoryTitle { get; set; } = null!;

    public string? CategoryStatus { get; set; }

    public DateTime? CategoryCdtm { get; set; }

    public DateTime? CategoryUdtm { get; set; }

    public string? CategoryLog { get; set; }

    public int? IsActive { get; set; }

    public int? CmpId { get; set; }
}
