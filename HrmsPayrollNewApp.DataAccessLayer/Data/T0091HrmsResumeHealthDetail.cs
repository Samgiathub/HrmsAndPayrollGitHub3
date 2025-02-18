using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0091HrmsResumeHealthDetail
{
    public decimal RowDId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? RowId { get; set; }

    public decimal? QueId { get; set; }

    public string? QueTag { get; set; }

    public string? AnswerTag { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0090HrmsResumeHealth? Row { get; set; }
}
