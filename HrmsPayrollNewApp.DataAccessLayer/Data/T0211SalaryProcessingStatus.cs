using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0211SalaryProcessingStatus
{
    public long TranId { get; set; }

    public int? Spid { get; set; }

    public string? GuidPart { get; set; }

    public int? TotalCount { get; set; }

    public int? Processed { get; set; }
}
