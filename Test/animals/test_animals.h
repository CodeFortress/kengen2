#include <iostream>
using namespace std;
class Animal
{
public:
    virtual void Append(ostream& stream)
    {
        stream << "Animal";
    }

    virtual bool IsSpecies() const
    {
        return false;
    }
};
class Mammal  : public Animal
{
public:
    typedef Animal super;
    virtual void Append(ostream& stream) override
    {
        super::Append(stream);
        stream << " >> ";
        stream << "Mammal";
    }

    virtual bool IsSpecies() const
    {
        return false;
    }
};
class Marsupial  : public Mammal
{
public:
    typedef Mammal super;
    virtual void Append(ostream& stream) override
    {
        super::Append(stream);
        stream << " >> ";
        stream << "Marsupial";
    }

    virtual bool IsSpecies() const
    {
        return false;
    }
};
class Koala final : public Marsupial
{
public:
    typedef Marsupial super;
    virtual void Append(ostream& stream) override
    {
        super::Append(stream);
        stream << " >> ";
        stream << "Koala";
    }

    virtual bool IsSpecies() const
    {
        return true;
    }
};
class Kangaroo final : public Marsupial
{
public:
    typedef Marsupial super;
    virtual void Append(ostream& stream) override
    {
        super::Append(stream);
        stream << " >> ";
        stream << "Kangaroo";
    }

    virtual bool IsSpecies() const
    {
        return true;
    }
};
class Ursidae  : public Mammal
{
public:
    typedef Mammal super;
    virtual void Append(ostream& stream) override
    {
        super::Append(stream);
        stream << " >> ";
        stream << "Ursidae";
    }

    virtual bool IsSpecies() const
    {
        return false;
    }
};
class GrizzlyBear final : public Ursidae
{
public:
    typedef Ursidae super;
    virtual void Append(ostream& stream) override
    {
        super::Append(stream);
        stream << " >> ";
        stream << "GrizzlyBear";
    }

    virtual bool IsSpecies() const
    {
        return true;
    }
};
class PolarBear final : public Ursidae
{
public:
    typedef Ursidae super;
    virtual void Append(ostream& stream) override
    {
        super::Append(stream);
        stream << " >> ";
        stream << "PolarBear";
    }

    virtual bool IsSpecies() const
    {
        return true;
    }
};
