using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100OptionalHolidayApplication
{
    public decimal OpHolidayAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal HdayId { get; set; }

    public DateTime OpHolidayDate { get; set; }

    public string OpHolidayStatus { get; set; } = null!;

    public string? OpHolidayComment { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime DateCreated { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? DateModified { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string EmpSecondName { get; set; } = null!;

    public string? BranchName { get; set; }

    public decimal? BranchId { get; set; }

    public string? EmpLeft { get; set; }

    public string? HFromDate { get; set; }

    public string? HToDate { get; set; }

    public string? OpHolidayAppDate { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string EmpLastName { get; set; } = null!;

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string HdayName { get; set; } = null!;

    public decimal EmpSuperior { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }
}
