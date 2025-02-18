using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsAppraisalInitiationFinal
{
    public decimal ApprIntId { get; set; }

    public int IsAccept { get; set; }

    public decimal EmpId { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? EmployeeSuperior { get; set; }

    public int? IsEmpSubmit { get; set; }

    public int? IsSupSubmit { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }
}
