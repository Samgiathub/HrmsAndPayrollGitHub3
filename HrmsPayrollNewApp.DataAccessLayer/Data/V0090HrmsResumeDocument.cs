using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsResumeDocument
{
    public string DocName { get; set; } = null!;

    public decimal ResumeId { get; set; }

    public decimal DocId { get; set; }

    public decimal DocTypeId { get; set; }

    public decimal CmpId { get; set; }

    public string FileName { get; set; } = null!;

    public decimal? ResumeFinalId { get; set; }
}
