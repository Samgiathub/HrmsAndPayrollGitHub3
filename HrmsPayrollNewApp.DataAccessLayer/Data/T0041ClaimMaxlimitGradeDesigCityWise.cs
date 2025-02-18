using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0041ClaimMaxlimitGradeDesigCityWise
{
    public decimal TranId { get; set; }

    public decimal ClaimId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal CityCatLimit { get; set; }

    public decimal CityCatId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public byte? FlagGrdDesig { get; set; }

    public byte? CityCatFlag { get; set; }

    public decimal CmpId { get; set; }

    public byte? HqFlag { get; set; }

    public virtual T0040ClaimMaster Claim { get; set; } = null!;

    public virtual T0040DesignationMaster? Desig { get; set; }

    public virtual T0040GradeMaster? Grd { get; set; }
}
