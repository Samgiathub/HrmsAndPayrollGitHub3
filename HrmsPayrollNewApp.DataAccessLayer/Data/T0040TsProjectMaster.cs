using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TsProjectMaster
{
    public decimal ProjectId { get; set; }

    public string? ProjectName { get; set; }

    public string? ProjectCode { get; set; }

    public string? ProjectDescription { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? DueDate { get; set; }

    public string? Duration { get; set; }

    public decimal? ProjectStatusId { get; set; }

    public string? TimeSheetApprovalType { get; set; }

    public decimal? ProjectCost { get; set; }

    public decimal? ClientId { get; set; }

    public int? Completed { get; set; }

    public int? Disabled { get; set; }

    public string? Attachment { get; set; }

    public string? Address1 { get; set; }

    public string? Address2 { get; set; }

    public decimal? LocId { get; set; }

    public decimal? StateId { get; set; }

    public string? Zipcode { get; set; }

    public string? PhoneNo { get; set; }

    public string? FaxNo { get; set; }

    public string? ContactPerson { get; set; }

    public string? ContactEmail { get; set; }

    public decimal? SpecialityId { get; set; }

    public string? ContractType { get; set; }

    public decimal? FedoraCharges { get; set; }

    public int? OverheadCalculation { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? City { get; set; }

    public decimal? BranchId { get; set; }

    public string? Savedby { get; set; }

    public virtual T0040ClientMaster? Client { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0011Login? CreatedByNavigation { get; set; }

    public virtual T0040ProjectStatus? ProjectStatus { get; set; }

    public virtual T0040SpecialityMaster? Speciality { get; set; }

    public virtual ICollection<T0040CollectionMaster> T0040CollectionMasters { get; set; } = new List<T0040CollectionMaster>();

    public virtual ICollection<T0040OverHeadMaster> T0040OverHeadMasters { get; set; } = new List<T0040OverHeadMaster>();

    public virtual ICollection<T0040TaskMaster> T0040TaskMasters { get; set; } = new List<T0040TaskMaster>();

    public virtual ICollection<T0050TaskDetail> T0050TaskDetails { get; set; } = new List<T0050TaskDetail>();

    public virtual ICollection<T0050TsProjectDetail> T0050TsProjectDetails { get; set; } = new List<T0050TsProjectDetail>();

    public virtual ICollection<T0110TsApplicationDetail> T0110TsApplicationDetails { get; set; } = new List<T0110TsApplicationDetail>();

    public virtual ICollection<T0130TsApprovalDetail> T0130TsApprovalDetails { get; set; } = new List<T0130TsApprovalDetail>();
}
