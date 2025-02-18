using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TblEmailDetail
{
    public decimal EmailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmailFromUserId { get; set; }

    public decimal EmailToUserId { get; set; }

    public string EmailSubject { get; set; } = null!;

    public string EmailMessages { get; set; } = null!;

    public DateTime EmailDatetime { get; set; }

    public string EmailType { get; set; } = null!;

    public decimal EmailFromStatus { get; set; }

    public decimal EmailToStatus { get; set; }

    public decimal? EmailReadStatus { get; set; }

    public string? EmailCss { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
