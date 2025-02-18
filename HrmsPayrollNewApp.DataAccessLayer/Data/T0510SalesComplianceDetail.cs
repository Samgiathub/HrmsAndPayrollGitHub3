using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0510SalesComplianceDetail
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CompId { get; set; }

    public string? ClientCode { get; set; }

    public string? EmpCode { get; set; }

    public DateTime? RegDate { get; set; }

    public string? CompDescription { get; set; }

    public decimal? CompAmount { get; set; }

    public DateTime? ResolvedDate { get; set; }

    public string? ResolvedDesc { get; set; }

    public decimal? UserId { get; set; }

    public DateTime? ModifyDate { get; set; }
}
