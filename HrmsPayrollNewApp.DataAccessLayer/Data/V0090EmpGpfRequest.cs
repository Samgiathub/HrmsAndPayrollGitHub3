using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpGpfRequest
{
    public long? RowNo { get; set; }

    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal AdId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal Amount { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }
}
