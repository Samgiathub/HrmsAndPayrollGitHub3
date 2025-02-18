using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsResumeImm
{
    public string? ImmType { get; set; }

    public string? ImmNo { get; set; }

    public string? ImmComments { get; set; }

    public decimal CmpId { get; set; }

    public decimal RowId { get; set; }

    public decimal ResumeId { get; set; }
}
