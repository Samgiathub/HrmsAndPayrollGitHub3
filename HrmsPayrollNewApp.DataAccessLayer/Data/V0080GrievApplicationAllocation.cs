using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080GrievApplicationAllocation
{
    public int GAllocationId { get; set; }

    public string? AppNo { get; set; }

    public int? CmpId { get; set; }

    public string? ComName { get; set; }

    public string? GrievanceTypeTitle { get; set; }

    public string? CategoryTitle { get; set; }

    public string? PriorityTitle { get; set; }

    public string? SName { get; set; }

    public string? AllocationDate { get; set; }

    public string? SubjectLine { get; set; }

    public string? GappDate { get; set; }
}
