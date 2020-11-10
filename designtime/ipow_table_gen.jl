#=
    This code is used to generate the integer power lookup tables.
    
    result of ipow(ipow_base::T, ipow_power::T) where {T}
      - either an overflow exception is generated
      - orelse the result is a positive integer of type `T`
          - result = ipow_base^ipow_power
          - result == BigInt(ipow_base)^BigInt(ipow_power)
      
    Each result is determined through exaustive search for overflow
    using Base.Int128s and DecFP.Dec128s. 
    
    The results are independently validated by comparison with 
      the results obtained using a different algorithmic approach
      and computed using BigInts exclusively.
=#
#=
    (maxint^10 that does not overflow, maxint == 78)
    (maxint^10 that does not overflow, maxint == 78)

=#

function pospow_safemax(base::T) where {T}
    pows = T(1):T(4096)
    for p in pows
        pospow_is_unsafe(base, p) && return p-1
    end
end

function pospow_unsafemin(base::T) where {T<:Signed}
    pows = T(4096):T(-1):T(1)
    for p in pows
        pospow_is_safe(base, p) && return p+1
    end    
    throw(ErrorException("Should not be reached"))
end

function pospow_is_safe(base::T, power::T) where {T<:Signed}
    issafe = true
    tresult = base^power
    bibase, bipower = BigInt(base), BigInt(power)
    biresult = bibase^bipower
    try
        converted_result = T(biresult)
    catch
        issafe = false
    end    
    issafe = issafe  & iszero(cmp(biresult,tresult)) & iszero(cmp(converted_result, biresult))
    return issafe
end

pospow_is_unsafe(base, power) = !pospow_is_safe(base, power)

using Base.Checked
#=
julia> names(Base.Checked)
14-element Vector{Symbol}:
 :Checked
 :add_with_overflow
 :checked_abs
 :checked_add
 :checked_cld
 :checked_div
 :checked_fld
 :checked_mod
 :checked_mul
 :checked_neg
 :checked_rem
 :checked_sub
 :mul_with_overflow
 :sub_with_overflow
=#

import DecFP, Quadmath
const D128 = DecFP.Dec128
const F128 = Quadmath.Float128

#=
   maxintfloat(Float128) [1.0e34] has 113 significant bits
      bit113 is set, bits112..1 are cleared
   maxintfloat(Float128) ~= 1.0e34 D1
      10384,593717,069655,257060,992658,440192
 
   We choose BigFloat precision to be large enough to resolve any outlier roundings,
     setprecision(BigFloat, 5*128)
=#

setprecision(BigFloat, 5*128)
Base.BigFloat(x::F128) = BigFloat(string(x))
Base.BigFloat(x::D128) = BigFloat(string(x))
F128(x::BigFloat) = parse(F128, string(x))
D128(x::BigFloat) = parse(D128, string(x))
Base.BigInt(x::F128) = BigInt(BigFloat(x))
Base.BigInt(x::D128) = BigInt(BigFloat(x))
F128(x::BigInt) = F128(BigFloat(x))
D128(x::BigInt) = D128(BigFloat(x))

# Parametric Constraints' Typwa
const ParamT = Int128
const PartsT = DecFP.Dec128

# Parametric Constraints
const ParamT = Int128
const PartsT = DecFP.Dec128

# Parametric Intervals
basemin = ParamT(2)
basemax = ParamT(128)
basetop = ParamT(1024)
powmin  = ParamT(2)
powmax  = ParamT(128)
powtop  = ParamT(1024)

# parametric domains
const allowed_bases   = collect(basemin:basemax);
const allowed_powers  = collect(powmin:powmax);
const possible_bases  = collect(basemin:basetop);
const possible_powers = collect(powmin:powtop);

