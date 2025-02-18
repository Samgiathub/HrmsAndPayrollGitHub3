using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090AppMaster
{
    public decimal AppId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? GradeId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? ShiftId { get; set; }

    public string? Initial { get; set; }

    public string AppFirstName { get; set; } = null!;

    public string? AppMiddleName { get; set; }

    public string AppLastName { get; set; } = null!;

    public DateTime? DateOfJoin { get; set; }

    public decimal? BasicSalary { get; set; }

    public string? Gender { get; set; }

    public string? MaritalStatus { get; set; }

    public DateTime? DateOfBirth { get; set; }

    public string? PrimaryEmail { get; set; }

    public string? OtherEmail { get; set; }

    public string? PresentStreet { get; set; }

    public string? PresentCity { get; set; }

    public string? PresentState { get; set; }

    public string? PresentPostBox { get; set; }

    public decimal? PresentLoc { get; set; }

    public string? HomeTelNo { get; set; }

    public string? MobileNo { get; set; }

    public string? PermanentStreet { get; set; }

    public string? PermanentCity { get; set; }

    public string? PermanentState { get; set; }

    public string? PermanentPostBox { get; set; }

    public string? AppFullName { get; set; }

    public decimal? Status { get; set; }

    public virtual T0030BranchMaster Branch { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DepartmentMaster? Dept { get; set; }

    public virtual T0040DesignationMaster? Desig { get; set; }

    public virtual T0040GradeMaster? Grade { get; set; }

    public virtual T0055ResumeMaster Resume { get; set; } = null!;

    public virtual T0040TypeMaster? Type { get; set; }
}
