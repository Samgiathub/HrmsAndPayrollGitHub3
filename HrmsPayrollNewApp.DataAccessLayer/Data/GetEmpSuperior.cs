using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class GetEmpSuperior
{
    public string? EmpLeft { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? DefId { get; set; }

    public decimal SuperiorId { get; set; }

    public string? EmpSuperior { get; set; }

    public DateTime? EmpLeftDate { get; set; }
}
