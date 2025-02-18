using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080EmpKpiObj
{
    public decimal EmpKpiId { get; set; }

    public decimal CmpId { get; set; }

    public int? Status { get; set; }

    public decimal EmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime CreatedDate { get; set; }

    public DateTime? LastEditDate { get; set; }

    public string? EmpFullName { get; set; }

    public string? CreatedByName { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? ApproveStatus { get; set; }

    public int? FinancialYr { get; set; }

    public string? EmpComments { get; set; }

    public string? MgrComments { get; set; }

    public string? HrComments { get; set; }

    public string? AlphaEmpCode { get; set; }
}
