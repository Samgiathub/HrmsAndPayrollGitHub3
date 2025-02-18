using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115TravelLevelApproval
{
    public decimal TranId { get; set; }

    public decimal? TravelApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ApprovalDate { get; set; }

    public string ApprovalStatus { get; set; } = null!;

    public string? ApprovalComments { get; set; }

    public decimal LoginId { get; set; }

    public decimal Total { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal RptLevel { get; set; }

    public byte ChkAdv { get; set; }

    public byte ChkAgenda { get; set; }

    public string? TourAgenda { get; set; }

    public string? ImpBusinessAppoint { get; set; }

    public string? KraTour { get; set; }

    public string? AttachedDocFile { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0115TravelApprovalAdvdetailLevel> T0115TravelApprovalAdvdetailLevels { get; set; } = new List<T0115TravelApprovalAdvdetailLevel>();

    public virtual ICollection<T0115TravelApprovalDetailLevel> T0115TravelApprovalDetailLevels { get; set; } = new List<T0115TravelApprovalDetailLevel>();

    public virtual ICollection<T0115TravelApprovalOtherDetailLevel> T0115TravelApprovalOtherDetailLevels { get; set; } = new List<T0115TravelApprovalOtherDetailLevel>();

    public virtual T0100TravelApplication? TravelApplication { get; set; }
}
