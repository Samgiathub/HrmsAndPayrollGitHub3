using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090HrmsResumeDocument
{
    public decimal DocId { get; set; }

    public decimal CmpId { get; set; }

    public decimal DocTypeId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal? ResumeFinalId { get; set; }

    public string FileName { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DocumentMaster DocType { get; set; } = null!;

    public virtual T0055ResumeMaster Resume { get; set; } = null!;

    public virtual T0060ResumeFinal? ResumeFinal { get; set; }
}
