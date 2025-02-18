using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080LoanHycScheme
{
    public decimal Srno { get; set; }

    public int? CmpId { get; set; }

    public decimal? RptLevel { get; set; }

    public decimal? SchemeIid { get; set; }

    public decimal? DynHierId { get; set; }

    public string? LoanTypeId { get; set; }

    public decimal? AppEmp { get; set; }

    public decimal? AppId { get; set; }

    public decimal? RptEmp { get; set; }

    public DateTime? CreateDate { get; set; }
}
