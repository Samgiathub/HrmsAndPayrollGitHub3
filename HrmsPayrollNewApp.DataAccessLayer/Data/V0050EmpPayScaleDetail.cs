using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050EmpPayScaleDetail
{
    public long? RowNo { get; set; }

    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal PayScaleId { get; set; }

    public string? PayScaleName { get; set; }

    public string? PayScaleDetail { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? BranchName { get; set; }

    public decimal BranchId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal GrdId { get; set; }
}
