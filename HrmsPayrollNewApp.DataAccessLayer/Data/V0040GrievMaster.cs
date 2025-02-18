using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040GrievMaster
{
    public int GrievanceTypeId { get; set; }

    public string? GrievanceTypeTitle { get; set; }

    public string GrievanceTypeCode { get; set; } = null!;

    public int? CmpId { get; set; }
}
