using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsEmpSupDashBoard
{
    public decimal ApprDetailId { get; set; }

    public decimal ApprIntId { get; set; }

    public decimal EmpId { get; set; }

    public int? IsEmpSubmit { get; set; }

    public int? IsSupSubmit { get; set; }

    public int? IsTeamSubmit { get; set; }

    public int IsAccept { get; set; }

    public DateTime? EmpSubmitDate { get; set; }

    public DateTime? SupSubmitDate { get; set; }

    public DateTime? TeamSubmitDate { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public decimal? EmpSuperior { get; set; }

    public decimal CmpId { get; set; }

    public string? EmpFullName { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpName { get; set; }

    public DateTime ForDate { get; set; }
}
