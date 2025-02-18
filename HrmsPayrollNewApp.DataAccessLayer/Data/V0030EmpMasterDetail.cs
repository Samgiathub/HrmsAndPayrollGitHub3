using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0030EmpMasterDetail
{
    public decimal EmpId { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BasicSalary { get; set; }

    public DateTime DateOfJoin { get; set; }

    public string? EmpLeft { get; set; }

    public string DesigName { get; set; } = null!;

    public string DeptName { get; set; } = null!;

    public string ShiftName { get; set; } = null!;

    public string CmpName { get; set; } = null!;

    public string GrdName { get; set; } = null!;

    public string CmpAddress { get; set; } = null!;

    public string CmpPhone { get; set; } = null!;

    public DateTime? DateOfBirth { get; set; }

    public string? MaritalStatus { get; set; }

    public string? Nationality { get; set; }

    public string? Street1 { get; set; }

    public string? City { get; set; }

    public string? State { get; set; }

    public string? ZipCode { get; set; }

    public string? HomeTelNo { get; set; }

    public string? MobileNo { get; set; }

    public string? WorkTelNo { get; set; }

    public string? WorkEmail { get; set; }

    public string? OtherEmail { get; set; }

    public string? PresentStreet { get; set; }

    public string? PresentCity { get; set; }

    public string? PresentState { get; set; }

    public string? PresentPostBox { get; set; }

    public DateTime? EmpLeftDate { get; set; }

    public string? BranchName { get; set; }
}
